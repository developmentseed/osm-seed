#!/usr/bin/env python3

import os
import boto3
from datetime import datetime
from botocore.exceptions import ClientError
import gzip

s3 = boto3.client("s3")


def write_monitoring_status(bucket_name, s3_file_name, list_):
    """Write output from monitoring the replication files.

    Args:
        bucket_name (str): bucket name
        s3_file_name (str): file name
        list_ (list): list of string to write in the file
    """
    dir_name = os.path.dirname(s3_file_name)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    list_str = "\n".join(map(str, list_)) + "\n"
    with open(s3_file_name, "w") as f:
        f.write(list_str)
    s3.upload_file(s3_file_name, bucket_name, f"replication_monitoring/{s3_file_name}")


def get_value_from_state(bucket, s3_key, file_value):
    """Retrieve the 'sequenceNumber' value from the state file.

    Args:
        bucket_name (str): bucket name
        s3_key (str): status file

    Returns:
        number: sequence number
    """
    local_file = "/tmp/state.txt"
    s3.download_file(bucket, s3_key, local_file)
    with open(local_file, "r") as file:
        for line in file:
            if line.startswith(f"{file_value}="):
                value = line.split("=")[1].strip()
                return value


def process_sequence(n):
    """Prefix the sequence number with zeros and divide it into groups

    Args:
        n (number): seqeunce number

    Returns:
        tuple: groups of string
    """
    s = str(n).zfill(9)
    return int(s[:3]), int(s[3:6]), int(s[6:])


def check_missing_files(bucket_name, key, end_seq):
    """Verify the absence of certain files in the bucket's folders.

    Args:
        bucket_name (str): bucket name
        key (str): folder name
        end_seq (number): last replication sequence

    Returns:
        list: List of missing files
    """
    print(f"Checking files...s3://{bucket_name}/{key}...range(0, {end_seq})")
    s3 = boto3.resource("s3")
    bucket = s3.Bucket(bucket_name)
    existing_files = [obj.key for obj in bucket.objects.filter(Prefix=key)]
    missing_files = []
    for i in range(1, end_seq):
        sequence_file = str(i).zfill(3)
        status_filename = os.path.join(key, "{}.state.txt".format(sequence_file))
        osm_filename = os.path.join(key, "{}.osc.gz".format(sequence_file))
        if status_filename not in existing_files:
            missing_files.append(status_filename)
        if osm_filename not in existing_files:
            missing_files.append(osm_filename)
    return missing_files


def get_missing_files(
    bucket_name,
    replication_folder,
    last_replication_sequence,
    start_monitoring_sequence,
):
    """Loop bucket's folder to get the missing files

    Args:
        bucket_name (str): bucket name
        replication_folder (str): replication folder
        last_replication_sequence (number): generated the last replication sequence using Osmosis.
        start_monitoring_sequence (_type_): start point of monitoring from previous tasks

    Returns:
        list: List of missing files
    """
    start_a, start_b, start_c = process_sequence(start_monitoring_sequence)
    end_a, end_b, end_c = process_sequence(last_replication_sequence)

    missing_files = []

    for a in range(start_a, end_a + 1):
        for b in range(start_b, end_b + 1):
            fixed_end_c = 1000
            if b == end_b:
                fixed_end_c = end_c + 1
            key = f"{replication_folder}/{str(a).zfill(3)}/{str(b).zfill(3)}"
            m_files = check_missing_files(bucket_name, key, fixed_end_c)
            missing_files = missing_files + m_files

    return missing_files


def create_state_file(bucket, filename):
    folder = os.path.dirname(filename)
    current_sequence = int(os.path.splitext(os.path.basename(filename))[0].replace(".state", ""))
    previous_sequence = current_sequence - 1
    previous_file = os.path.dirname(filename) + "/" + str(previous_sequence).zfill(3) + ".state.txt"
    date_str = get_value_from_state(bucket, previous_file, "timestamp")
    current_sequence_number = int(folder.split("/")[2] + folder.split("/")[3] + str(current_sequence).zfill(3))
    content = f"sequenceNumber={current_sequence_number} \ntxnMaxQueried=6182454 \ntxnActiveList= \ntxnReadyList= \ntxnMax=6182454 \ntimestamp={date_str}"
    os.makedirs(folder, exist_ok=True)
    with open(filename, "w") as f:
        f.write(content)
    print(f"Updating missing file... {filename} to s3://{bucket_name}/{filename} ")
    s3.upload_file(filename, bucket_name, f"{filename}")

def create_osc_file(bucket_name, filename):
    content = """<?xml version='1.0' encoding='UTF-8'?>\n\t<osmChange version="0.6" generator="Osmosis 0.48.0-SNAPSHOT">\n</osmChange>"""
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    filename_osc = filename.replace(".gz", "")
    with open(filename_osc, "w") as f:
        f.write(content)
    with open(filename_osc, "rb") as f_in:
        with gzip.open(filename_osc + ".gz", "wb") as f_out:
            f_out.writelines(f_in)
    print(f"Updating missing file {filename} to s3://{bucket_name}/{filename} ")
    s3.upload_file(filename, bucket_name, f"{filename}")


if __name__ == "__main__":
    bucket_name = os.environ["AWS_S3_BUCKET"]
    bucket_name = bucket_name.replace("s3://", "")
    replication_folder = os.environ["REPLICATION_FOLDER"]
    create_missing_files = os.getenv("CREATE_MISSING_FILES", "empty")

    ## Get last sequence file from replication/minute
    STATE_FILE = f"{replication_folder}/state.txt"
    last_replication_sequence = int(get_value_from_state(bucket_name, STATE_FILE, "sequenceNumber"))

    ## Get last monitoring sequence number
    try:
        STATE_MISSING_FILE = "replication_monitoring/state.txt"
        start_monitoring_sequence = int(get_value_from_state(bucket_name, STATE_MISSING_FILE, "sequenceNumber"))
    except ClientError as e:
        start_monitoring_sequence = int(os.environ["REPLICATION_SEQUENCE_NUMBER"])

    missing_files = get_missing_files(
        bucket_name,
        replication_folder,
        last_replication_sequence,
        start_monitoring_sequence,
    )

    ## Print error to monitoring (new relic)
    if len(missing_files) > 0:
        for f in missing_files:
            print(f"Error, {f} is missing")
        now = datetime.now()
        date_str = now.strftime("%Y_%m_%d-%H-%M")
        write_monitoring_status(bucket_name, f"missing/{date_str}.txt", missing_files)

        # Write missing files in s3
        if create_missing_files == "empty":
            for file in missing_files:
                file_extension = os.path.splitext(file)[1]
                if file_extension == ".txt":
                    create_state_file(bucket_name, file)
                if file_extension == ".gz":
                    create_osc_file(bucket_name, file)

    ## Write state file
    write_monitoring_status(
        bucket_name, "state.txt", [f"sequenceNumber={last_replication_sequence}"]
    )
