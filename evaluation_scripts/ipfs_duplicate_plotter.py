#!/usr/bin/env python3
import matplotlib.pyplot as plt
import json
import numpy as np
import argparse
from os import listdir
from os.path import join
from collections import defaultdict

save_dir = './evaluation_scripts/Plots/'

def parse_line(line):
    d = json.loads(line)
    return int(d['Users']),float(d['DupBlocks'])

def parse_file(file):
    users = []
    duplicate_blocks = []
    with open(file) as fp:
        line = fp.readline()
        while line:
            output = parse_line(line)
            users.append(output[0])
            duplicate_blocks.append(output[1])
            line = fp.readline()
    return users, duplicate_blocks

def linear_reg(xx,yy):
    A = np.vstack([xx, np.ones(len(xx))]).T
    m, c = np.linalg.lstsq(A, yy)[0]
    y_fit = m*np.array(xx).astype(float) + c
    return y_fit

def combine_iterations(file):
    results_agg = defaultdict(list)

    for idx, file_path in enumerate(listdir(file)):
        users, duplicate_blocks = parse_file(join(file, file_path))
        if len(results_agg) == 0:
            list_size = len(users)
            results_agg["users"]   = [0]*list_size
            results_agg["duplicate_blocks"] = [0]*list_size

        results_agg["users"]            =[sum(x) for x in zip(results_agg["users"],   users)]
        results_agg["duplicate_blocks"] =[sum(x) for x in zip(results_agg["duplicate_blocks"], duplicate_blocks)]

    num_iterations = len(listdir(file))
    for idx in range(len(results_agg["users"])):
        results_agg["users"][idx]            =(results_agg["users"][idx]  / num_iterations)
        results_agg["duplicate_blocks"][idx] =(results_agg["duplicate_blocks"][idx] / num_iterations)

    return results_agg["users"], results_agg["duplicate_blocks"]

# Usage: evaluation_scripts/ipfs_duplicate_plotter.py -d -trend
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Command Line Interface')
    parser.add_argument('-o', type=str, nargs='?',
                        help="Save output to the specified directory")
    parser.add_argument('-d',action='store_true', default = False,
                        help="Show simulation with lattency added")
    parser.add_argument('-trend',action='store_true', default = False,
                        help="Show performance trendline")

    args = parser.parse_args()
    fig, ax1 = plt.subplots()
    # If you want to plot the dataset with latency
    if args.d:
        xx,YY = combine_iterations('./json/')
        plt.plot(xx,YY,'x', color='orange', label='Latency Data Points')
        # If you want to add a trendline
        if args.trend:
            yy_fit = linear_reg(xx,YY)
            plt.plot(xx, yy_fit, color='orange', alpha=0.8, label='Latency Trendline')

    # Plot the standard IPFS duplicate blocks
    x,Y = combine_iterations('./json/')
    plt.plot(x,Y,'x', color = 'red', label='Zero latency Data Points')
    # If you want to add a trendline
    if args.trend:
        y_fit = linear_reg(x,Y)
        plt.plot(x, y_fit, color = 'blue', alpha=0.5, label='Zero Latency Trendline')

    # Add labels to axis and plot
    plt.ylabel('Duplicate Blocks')
    plt.xlabel('Number of users in the swarm')
    plt.legend()
    if args.o != None:
        fig.savefig(save_dir + args.o +'.png',bbox_inches='tight')
    else:
        plt.show()
