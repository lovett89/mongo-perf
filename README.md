# mongo-perf
This is a benchmark tool for the MongoDB server.

### Overview
============
This repo contains scripts to run benchmark tests for mongodb. It also includes some scripts that perform anomaly detection (herein called analysis) and reporting on historical benchmark tests. See [Local Usage](#local) or [Buildbot Usage](#buildbot) for more information.


### Dependencies
================
##### Benchmarks
* Scons
* Python >= 2.7.X (X >= 2)
* pymongo
* MongoDB
* git (optional)
* C++ build environment
* Boost C++ Libraries

##### Analysis
* Python >= 2.7.X (X >= 2)
* pymongo
* MongoDB
* R >= 2.15.0
* rmongodb

##### Reporting
* boto (optional)
* Amazon SES® (optional) 

### <a name="local"></a>Local Usage
---------------
The runner script has a `--local` flag which is used to differentiate between local machine runs and buildbot runs. Use the `--multidb` flag to indicate if you want a single database or multiple databases for each connection (by default, mongo-perf writes to a `bench_results` database).

##### Benchmarks
<pre><code># compile the C++ driver
cd mongo-cxx-driver && scons 
# compile the benchmark script
scons benchmark 

To run on an already existing mongod:

	(start mongod on 27017 to test against and record 
	the results into)

	# this runs the tests and records the results
	# optionally supply a label as well using -l
	# use -h for help message
	python runner.py --nolaunch -l HOSTNAME -n 1 --local

To run it against the source on github:
	
	# this pulls and starts mongod from the github repo,
	# runs the tests and records the results
	# optionally supply a label as well using -l
	# use -h for help message
	python runner.py -l HOSTNAME -n 1 --local

# this serves the results on port 8080
# use --reload for debugging
python server.py 

Go to http://localhost:8080 to see the results
</code></pre>
You can setup a virtual environment if you wish. Note, however, that you still need to install the non-python dependencies. To use virutalenv:
<pre><code>virtualenv --no-site-packages mongo-perf
cd mongoperf
source bin/activate
# pull mongo-perf
git clone https://github.com/mongodb/mongo-perf
# install python dependencies &ndash; boto, bottle, pymongo
cd mongo-perf
pip install -r requirements.txt
# as at the time of this writing, scons doesn't 
# install with pip so you have to install using:
wget http://prdownloads.sourceforge.net/scons/scons-2.3.0.tar.gz
tar xzfv scons-2.3.0.tar.gz 
cd scons-2.3.0
python setup.py install
# compile the C++ driver
cd ../mongo-cxx-driver && scons 
# compile the benchmark script
scons benchmark 

To run on an already existing mongod:

	(start mongod on 27017 to test against and record 
	the results into)

	# this runs the tests and records the results
	# optionally supply a label as well using -l
	# use -h for help message
	python runner.py --nolaunch -l HOSTNAME -n 1 --local

To run it against the source on github:
	
	# this pulls and starts mongod from the github repo,
	# runs the tests and records the results
	# optionally supply a label as well using -l
	# use -h for help message
	python runner.py -l HOSTNAME -n 1 --local

# this serves the results on port 8080
# ensure that MONGO_PERF_HOST & MONGO_PERF_PORT in server.py
# are set accordingly - (same as --rhost --rport)
# use --reload for debugging
python server.py 

Go to http://localhost:8080 to see the results
</code></pre>

##### Analysis

Use `alerting.ini` and `reporting.ini` as a starting point to describe the kinds of alerts or reports you want generated. The sample files have only one entry but you can define as many alerts/reports as you like.

`analysismgr.py` defines pipelines &mdash; ALERT_TASKS and REPORT_TASKS &mdash; which control the flow of data processing. Definition parameters for alerts/reports are described in `alert_definitions.ini` and `report_definitions.ini` respectively &ndash; you can define as many as you wish. **All fields enumerated and documented in the sample '.ini' files are required**.

*Note that you need at least three days' worth of data to run* `analysismgr.py`.
<pre><code># this runs the whole pipeline of analysis and reporting
python analysismgr.py</code></pre>
Logs are written to stdout and `mongo-perf-log.txt` when you run `analysismgr.py`

##### Reporting
The default pipeline for both alerts and reports (as listed in ALERT_TASKS and REPORT_TASKS in `analysismgr.py`) show the result of the alerts/reports processing using your default web browser.

If you wish to receive email reports, change the last stage in pipeline in `analysismgr.py` to 'send reports' for reports, and 'send alerts' for alerts. Emails are sent using Amazon SES® so you will need an account on that to send reports (be sure to have your `aws_access_key_id` and `aws_secret_access_key` under `[Credentials]` in /etc/boto.cfg). See [here](https://code.google.com/p/boto/wiki/BotoConfig) for more information.

*By default, all analysis/reporting run against a `mongod` on port `27017` (mongod must be running on this port). To specify a different host, change* MONGO_PERF_HOST *and* MONGO_PERF_PORT *in `analysismgr.py`,`jobsmgr.py` and `mongo-perf.R`.*

#### <a name="buildbot"></a>Buildbot Usage
-------------------
##### Benchmarks
A call to this script by a buildslave might be:
<pre><code>python runner.py --rhost localhost --rport 27017 --port 30000  --mongod MONGO_DIR/mongod  --label Linux_64-bit
</code></pre>
The snippet above starts `mongod` on port 30000 (which it tests against) and writes the result of the benchmark tests to `localhost` on port `27017`. You can have both `--port` and `--rport` be the same. Note that we do not use the `--local` flag &ndash; without this flag, by default, running `python runner.py`, does two things: it uses a single database for each connection, and also uses a separate db for each connection and benchmarks for both.

If running benchmarks on a buildslave and analysis as a cron job, ensure that you call analysis only _after_ the benchmark tests have been completed.

*Analysis and Reporting work the same way as on local machines*.
