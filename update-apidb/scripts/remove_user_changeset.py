# encoding=utf8
#!/usr/bin/python
import sys
import string
from lxml import etree
import sys
reload(sys)
sys.setdefaultencoding('utf8')
osmfilename = sys.argv[1] if (len(sys.argv) > 1) else sys.exit("Invalid file name")
tree = etree.parse(osmfilename)
modifies = tree.findall(".//modify")
deletes = tree.findall(".//delete")
creates = tree.findall(".//create")

for modify in modifies:
  nodes = modify.findall(".//node")
  for node in nodes:
    del node.attrib["uid"]
    del node.attrib["changeset"]
    del node.attrib["user"]
  ways = modify.findall(".//way")
  for way in ways:
    del way.attrib["uid"]
    del way.attrib["changeset"]
    del way.attrib["user"]
  relations = modify.findall(".//relation")
  for relation in relations:
    del relation.attrib["uid"]
    del relation.attrib["changeset"]
    del relation.attrib["user"]

for create in creates:
  nodes = create.findall(".//node")
  for node in nodes:
    del node.attrib["uid"]
    del node.attrib["changeset"]
    del node.attrib["user"]
  ways = create.findall(".//way")
  for way in ways:
    del way.attrib["uid"]
    del way.attrib["changeset"]
    del way.attrib["user"]
  relations = create.findall(".//relation")
  for relation in relations:
    del relation.attrib["uid"]
    del relation.attrib["changeset"]
    del relation.attrib["user"]

for delete in deletes:
  nodes = delete.findall(".//node")
  for node in nodes:
    del node.attrib["uid"]
    del node.attrib["changeset"]
    del node.attrib["user"]
  ways = delete.findall(".//way")
  for way in ways:
    del way.attrib["uid"]
    del way.attrib["changeset"]
    del way.attrib["user"]
  relations = delete.findall(".//relation")
  for relation in relations:
    del relation.attrib["uid"]
    del relation.attrib["changeset"]
    del relation.attrib["user"]
xml = "<?xml version='1.0' encoding='UTF-8'?>\n"+etree.tostring(tree, encoding='utf8')
new_file = open(sys.argv[2], 'w')
new_file.write(xml)