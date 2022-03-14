import argparse
import os

def check_result(sim_model_out, ps_dump_out):
    sim_outfile = open(sim_model_out)
    internal_outfile = open(ps_dump_out)

    sim_out = [int(ps, 16) for ps in sim_outfile.readlines()][:-1]
    internal_out = [int(ps.partition("_")[2], 16) for ps in internal_outfile.readlines() if int(ps.partition("_")[2], 16) >= 0x10000]

    passed = True

    if(len(sim_out) >= len(internal_out)):
        passed = False
    else:
        last_inst = sim_out[-1] + 4
        for i in range(len(internal_out)):
            if(i < len(sim_out)):
                if(sim_out[i] != internal_out[i]):
                    passed = False
                    break
            else:
                if(internal_out[i] != last_inst):
                    passed = False
                    break
    return passed

    

parser = argparse.ArgumentParser(description='Checks if openlane simulation is accurate with simulation model.')

parser.add_argument('sim_type', help='Type of the simulation.')

args = parser.parse_args()
sim_type = args.sim_type

pwd = os.getcwd() + "/verilog/dv/test_c0"

if(sim_type == "RTL"):
    if(check_result(pwd + "/sim_ps.txt", pwd + "/ps_dump_internal.txt")):
        print("Internal dump passed.")
    else:
        print("Internal dump failed.")

if(check_result(pwd + "/sim_ps.txt", pwd + "/ps_dump_io.txt")):
    print("IO dump passed.")
else:
    print("IO dump failed.")

if(sim_type == "RTL"):
    os.system("mv " + pwd + "/ps_dump_internal.txt " + pwd + "/RTL-ps_dump_internal.txt")
    os.system("mv " + pwd + "/ps_dump_io.txt " + pwd + "/RTL-ps_dump_io.txt")
elif(sim_type == "GL"):
    os.system("mv " + pwd + "/ps_dump_io.txt " + pwd + "/GL-ps_dump_io.txt")