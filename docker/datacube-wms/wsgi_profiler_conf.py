import cProfile
import pstats
import io
import logging
import os
import time

PROFILE_LIMIT = int(os.environ.get("PROFILE_LIMIT", 30))
PROFILER = bool(int(os.environ.get("PROFILER", 1)))
FILE_PATH = os.environ.get("PROFILE_PATH", "prof/")

print("""
# ** USAGE:
$ PROFILE_LIMIT=100 gunicorn -c ./wsgi_profiler_conf.py wsgi
# ** TIME MEASUREMENTS ONLY:
$ PROFILER=0 gunicorn -c ./wsgi_profiler_conf.py wsgi
""")

try:
    os.mkdir(FILE_PATH)
except Exception:
    pass


def profiler_enable(worker, req):
    worker.profile = cProfile.Profile()
    worker.profile.enable()
    worker.log.info("PROFILING %d: %s" % (worker.pid, req.uri))

def profiler_summary(worker, req):
    s = io.StringIO()
    worker.profile.disable()
    ps = pstats.Stats(worker.profile, stream=s).sort_stats('time', 'cumulative')
    ps.dump_stats(FILE_PATH + str(worker.start_time))

    logging.error("\n[%d] [INFO] [%s] URI %s" % (worker.pid, req.method, req.uri))
    logging.error("[%d] [INFO] %s" % (worker.pid, s.getvalue()))


def pre_request(worker, req):
    worker.start_time = time.time()
    if PROFILER is True:
        profiler_enable(worker, req)


def post_request(worker, req, *args):
    total_time = time.time() - worker.start_time
    logging.error("\n[%d] [INFO] [%s] Load Time: %.3fs\n" % (
        worker.pid, req.method, total_time))
    if PROFILER is True:
        profiler_summary(worker, req)
