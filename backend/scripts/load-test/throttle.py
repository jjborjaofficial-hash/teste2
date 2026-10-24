#!/usr/bin/env python3
# Limita um processo a ~10% de um núcleo (como a Render gratuita: 0,1 CPU) alternando SIGCONT/SIGSTOP (o que o cpulimit faz).
import os, signal, sys, time
pid = int(sys.argv[1]); duty = float(sys.argv[2]) if len(sys.argv) > 2 else 0.10
period = 0.1
try:
    while True:
        os.kill(pid, signal.SIGCONT); time.sleep(period * duty)
        os.kill(pid, signal.SIGSTOP); time.sleep(period * (1 - duty))
except (ProcessLookupError, KeyboardInterrupt):
    pass
finally:
    try: os.kill(pid, signal.SIGCONT)
    except Exception: pass
