import os
import boto3
import tempfile
from datetime import datetime

s3 = boto3.client("s3")

# Upload the file
def write_list_to_s3(bucket_name, s3_file_name, list_):
    list_str = "\n".join(map(str, list_)) + "\n"
    with open(s3_file_name, 'w') as f:
        f.write(list_str)
    s3.upload_file(s3_file_name, bucket_name, f"replication_monitoring/{s3_file_name}")


def get_last_sequence_number(bucket, key):
    local_file = "/tmp/state.txt"
    s3.download_file(bucket, key, local_file)
    with open(local_file, "r") as file:
        for line in file:
            if line.startswith("sequenceNumber="):
                sequence_number = int(line.split("=")[1].strip())
                return sequence_number


def process_number(n):
    s = str(n).zfill(9)
    return int(s[:3]), int(s[3:6]), int(s[6:])


def check_missing_files(bucket_name, key, end_seq):
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


bucket_name = os.environ["AWS_S3_BUCKET"]
bucket_name = bucket_name.replace("s3://", "")
replication_folder = os.environ["REPLICATION_FOLDER"]
replication_sequence_number = int(os.environ["REPLICATION_SEQUENCE_NUMBER"])

## Get start num files
start_a, start_b, start_c = process_number(replication_sequence_number)

# Get latest replication sequence
STATE_FILE = f"{replication_folder}/state.txt"
last_sequence = get_last_sequence_number(bucket_name, STATE_FILE)
end_a, end_b, end_c = process_number(last_sequence)

missing_files = []

for a in range(start_a, end_a + 1):
    for b in range(start_b, end_b + 1):
        fixed_end_c = 1000
        if b == end_b:
            fixed_end_c = end_c + 1
        key = f"{replication_folder}/{str(a).zfill(3)}/{str(b).zfill(3)}"
        m_files = check_missing_files(bucket_name, key, fixed_end_c)
        missing_files = missing_files + m_files

if len(missing_files) > 0:
    for f in missing_files:
        print(f"Error, {f} is missing")
    now = datetime.now()
    date_str = now.strftime("%Y_%m_%d-%H-%M")
    write_list_to_s3(
        bucket_name, f"missing_{date_str}.txt", missing_files
    )

write_list_to_s3(
    bucket_name, "state.txt", [f"sequenceNumber={last_sequence}"]
)
