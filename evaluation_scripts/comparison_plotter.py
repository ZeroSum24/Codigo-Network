#!/usr/bin/env python3
import json
import matplotlib.pyplot as plt
from scipy import stats
import numpy as np
import argparse
from os import listdir
from os.path import join
from collections import defaultdict

save_dir = './evaluation_scripts/Plots/'

def linear_reg(xx,yy):
    A = np.vstack([xx, np.ones(len(xx))]).T
    m, c = np.linalg.lstsq(A, yy)[0]
    y_fit = m*np.array(xx).astype(float) + c
    return y_fit

def parse_single_line(line, filepath, prv_users):
    d = json.loads(line)
    users = int(d['Users'])
    if prv_users and users - prv_users < 4:
        return
    if users > 110:
        return

    return d['Users'], d['Avg_time'],d['Std_Time'], np.max(d['Results']),np.min(d['Results']),d['Results']

def parse_file(filepath):
    user_no = []
    delay_avg = []
    delay_std = []
    delay_max = []
    delay_min = []
    results = []
    prv_users = None
    with open(filepath) as fp:
        line = fp.readline()
        while line:
            res = parse_single_line(line,filepath,prv_users)
            if res is not None:
                prv_users = res[0]
                user_no.append(res[0])
                delay_avg.append(res[1])
                delay_std.append(res[2])
                delay_max.append(res[3])
                delay_min.append(res[4])
                results.append(res[5])
            line = fp.readline()
    print(user_no)
    return user_no, delay_avg, delay_std, delay_max, delay_min, results

def combine_iterations(filepath):
    results_agg = defaultdict(list)

    # aggregate the results
    for idx, file_path in enumerate(listdir(filepath)):
        user_no, delay_avg, delay_std, delay_max, delay_min,_ = parse_file(join(filepath, file_path))
        if len(results_agg) == 0:
            list_size = len(user_no)
            results_agg["user_no"]   = [0]*list_size
            results_agg["delay_avg"] = [0]*list_size
            results_agg["delay_std"] = [0]*list_size
            results_agg["delay_max"] = [0]*list_size
            results_agg["delay_min"] = [0]*list_size

        results_agg["user_no"]   =[sum(x) for x in zip(results_agg["user_no"],   user_no)]
        results_agg["delay_avg"] =[sum(x) for x in zip(results_agg["delay_avg"], delay_avg)]
        results_agg["delay_std"] =[sum(x) for x in zip(results_agg["delay_std"], delay_std)]
        results_agg["delay_max"] =[sum(x) for x in zip(results_agg["delay_max"], delay_max)]
        results_agg["delay_min"] =[sum(x) for x in zip(results_agg["delay_min"], delay_min)]

    num_iterations = len(listdir(filepath))

    # average the results
    for idx in range(len(results_agg["user_no"])):
        results_agg["user_no"][idx]   =(results_agg["user_no"][idx]   / num_iterations)
        results_agg["delay_avg"][idx] =(results_agg["delay_avg"][idx] / num_iterations)
        results_agg["delay_std"][idx] =(results_agg["delay_std"][idx] / num_iterations)
        results_agg["delay_max"][idx] =(results_agg["delay_max"][idx] / num_iterations)
        results_agg["delay_min"][idx] =(results_agg["delay_min"][idx] / num_iterations)

    return results_agg["user_no"], results_agg["delay_avg"], results_agg["delay_std"], results_agg["delay_max"], results_agg["delay_min"]


def plot(filepath,label,colour_,limit, trendline):
    user_no, delay_avg, delay_std, delay_max, delay_min = combine_iterations(filepath)
    if trendline:
        y_trendline = linear_reg(user_no,delay_avg)
        plt.plot(user_no, y_trendline,'-', color=colour_, alpha=0.2, label= label + " Trendline")

    plt.plot(user_no[:limit], delay_avg[:limit], 'o--', color=colour_, label=label + " Average delay",ms=3) #, yerr = delay_std, fmt='o' )
    plt.plot(user_no[:limit], delay_max[:limit], '--',  color=colour_, label=label + " Max delay",alpha=0.3)
    plt.plot(user_no[:limit], delay_min[:limit], '--',  color=colour_, label=label + " Min delay",alpha=0.3)
    plt.fill_between(user_no[:limit],
                     delay_max[:limit],
                     delay_min[:limit],
                     color =colour_,
                     alpha=0.2 )
    plt.locator_params(nbins=14)
    plt.xlabel('Number of Nodes')
    plt.ylabel('Average delay[sec]')
    print(type(limit))
    plt.xlim(0,limit)


def statistics(filepath):
    results = parse_file(filepath)
    for results_row in results[5]:
        print(stats.describe(results_row))
        print("==========================================")


ipfs_path = './json/'
server_path = './evaluation_scripts/datasets/server_results_single.json'
server_path_multi = './evaluation_scripts/datasets/server_results_multi.json'
bittorent_path = './evaluation_scripts/datasets/bittorent_results.json'
ipfs_with_delay = './evaluation_scripts/datasets/ipfs_duplicates_lat.json'

# USAGE: ./evaluation_scripts/results_parser.py -o ipfs-vs-BitTorrent -IPFS -BitTorrent
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Command Line Interface')
    parser.add_argument('-o', type=str, nargs='?',
                        help="Save output to the specified directory")
    parser.add_argument('-d',action='store_true', default = False,
                        help="Show simulation with lattency added")
    parser.add_argument('-trend',action='store_true', default = False,
                        help="Show performance trendline")
    parser.add_argument('-IPFS', action='store_true', default = False,
                    help='Show IPFS performance')
    parser.add_argument('-user_limit', type=int, nargs='?', default = 120,
                    help='Limit number of users')
    parser.add_argument('-BitTorrent', action='store_true', default = False,
                    help='Show BitTorrent performance')
    parser.add_argument('-client_server', action='store_true', default = False,
                    help='Show Client Server performance')
    parser.add_argument('-statistics', action='store_true', default = False,
                    help='Print statistics')
    args = parser.parse_args()
    fig, ax1 = plt.subplots()

    if args.IPFS:
        plot(ipfs_path, "IPFS",'blue',args.user_limit, args.trend)
        if args.d:
            plot(ipfs_with_delay, "IPFS Latency",'green',args.user_limit, args.trend)
        if args.statistics:
            statistics(ipfs_path)
    if args.BitTorrent:
        plot(bittorent_path,"BitTorrent",'orange',args.user_limit, args.trend)
        if args.statistics:
            statistics(bittorent_path)
    if args.client_server:
        plot(server_path,"Client Server",'red',args.user_limit, args.trend)
        #plot(server_path_multi,"Client Server Multithreaded",'green', args.user_limit)

    plt.legend()
    if args.o != None:
        fig.savefig(save_dir + args.o +'.png',bbox_inches='tight')
    else:
        plt.show()
