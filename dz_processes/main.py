import os

def read_stat(pid):
    stat_file = f"/proc/{pid}/stat"
    try:
        with open(stat_file, 'r') as f:
            data = f.read().split()
        return data
    except IOError:
        return None

def read_cmdline(pid):
    cmdline_file = f"/proc/{pid}/cmdline"
    try:
        with open(cmdline_file, 'r') as f:
            data = f.read().replace('\0', ' ').strip()
        return data if data else f"[{pid}]"
    except IOError:
        return f"[{pid}]"

def read_tty(pid):
    try:
        tty_nr = int(read_stat(pid)[6])
        tty_device = f"/dev/tty{tty_nr}" if tty_nr > 0 else "?"
        return tty_device
    except:
        return "?"

def get_process_info(pid):
    stat = read_stat(pid)
    if not stat:
        return None
    
    pid = stat[0]
    state = stat[2]
    utime = int(stat[13])
    stime = int(stat[14])
    
    total_time = utime + stime
    total_seconds = total_time // os.sysconf(os.sysconf_names['SC_CLK_TCK'])
    minutes = total_seconds // 60
    seconds = total_seconds % 60
    cpu_time = f"{minutes}:{seconds:02d}"
    
    tty = read_tty(pid)
    cmdline = read_cmdline(pid)
    
    return {
        "pid": pid,
        "tty": tty,
        "state": state,
        "cpu_time": cpu_time,
        "cmdline": cmdline
    }

def format_process_info(proc_info):
    pid = proc_info["pid"]
    tty = proc_info["tty"]
    state = proc_info["state"]
    cpu_time = proc_info["cpu_time"]
    cmdline = proc_info["cmdline"]
    
    return f"{pid:>5} {tty:<8} {state:<4} {cpu_time:>6} {cmdline}"

def main():
    pids = [pid for pid in os.listdir('/proc') if pid.isdigit()]
    print(f"{'PID':>5} {'TTY':<8} {'STAT':<4} {'TIME':>6} CMD")
    for pid in sorted(pids):
        proc_info = get_process_info(pid)
        if proc_info:
            print(format_process_info(proc_info))

if __name__ == "__main__":
    main()
