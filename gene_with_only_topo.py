#====================================================================================================================
# Author: Alfred Hou
# E-mail: 825526231@qq.com
# Any question can send the e-mail to me
# Time: 2024/01/11
#====================================================================================================================

import sys
import csv
from collections import defaultdict
from ete3 import Tree

def get_topology_string(tree):
    # Sort each node by the name of its children and generate a string representing the topology of that node
    topology_str = []
    for node in tree.traverse():
        if len(node.children) > 0:
            sorted_child_names = sorted([c.name for c in node.children])
            topology_str.append(f"{node.name}({','.join(sorted_child_names)})")

    return ';'.join(topology_str)

def classify_topologies(input_file, output_file):
    topology_counts = defaultdict(int)
    gene_to_topology = {}

    with open(input_file, 'r') as csvfile:
        reader = csv.reader(csvfile, delimiter='\t')

        for row in reader:
            gene_name, newick_tree = row[0], row[1]
            tree = Tree(newick_tree)
            topology_str = get_topology_string(tree)

            topology_counts[topology_str] += 1
            gene_to_topology[gene_name] = topology_str

    # Export genes and their corresponding topologies to file
    with open(output_file, 'w', newline='') as out:
        writer = csv.writer(out, delimiter='\t')
        writer.writerow(['Gene_ID', 'Topology'])
        for gene, topology in gene_to_topology.items():
            writer.writerow([gene, topology])

    return gene_to_topology

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script_name.py input.csv output.txt")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    gene_topologies = classify_topologies(input_file, output_file)
    print(f'Successfully wrote gene-to-topology classifications to {output_file}')

