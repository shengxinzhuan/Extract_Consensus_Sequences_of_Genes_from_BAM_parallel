import sys
from collections import defaultdict
from ete3 import Tree, TreeNode

#====================================================================================================================
# Author: Alfred Hou
# E-mail: 825526231@qq.com
# Any question can send the e-mail to me
# Time: 2024/01/11
#====================================================================================================================

def get_topology_string(tree):
    # Sort each node by the name of its children and generate a string representing the topology of that node 
    topology_str = []
    for node in tree.traverse():
        if len(node.children) > 0:
            sorted_child_names = sorted([c.name for c in node.children])
            topology_str.append(f"{node.name}({','.join(sorted_child_names)})")

    return ';'.join(topology_str)

def count_unique_topologies(newick_file, output_file):
    topology_counts = defaultdict(int)
    unique_topologies = []

    with open(newick_file, 'r') as f:
        for line in f:
            tree = Tree(line.strip())
            topology_str = get_topology_string(tree)
            
            topology_counts[topology_str] += 1
            if topology_counts[topology_str] == 1:  # Record the first occurrence of the topology
                unique_topologies.append((topology_str, tree))

    # Output the statistics to a file, while saving a tree for each topology (Newick format)
    with open(output_file, 'w') as out:
        out.write('Unique topologies and their counts:\n')
        for topology, tree in unique_topologies:
            out.write(f'Topology: {topology}\nCount: {topology_counts[topology]}\nTree Newick: {tree.write()}\n\n')

    return len(unique_topologies)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script_name.py input_trees.txt output_stats.txt")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    unique_topology_count = count_unique_topologies(input_file, output_file)
    print(f'Successfully wrote statistics to {output_file}')
