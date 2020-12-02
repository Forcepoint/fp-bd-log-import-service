# bd-dep-log-import-service
This is a Forcepoint AWS S3 log service used to download Forcepoint logs.

## Package

```bash
./build/create-deployment.sh
```

## Implementation

```bash
sudo tar -zxvf fp-aws-log-import-service-v1.tar.gz -C /opt/
```

### Setup the AWS credentials in order to access Forcepoint logs, this script will ask you to provide the AWS Access Key ID and the AWS Secret Key

```bash
sudo chmod +x /opt/fp-aws-log-import-service/setup-aws-credentials.sh
/opt/fp-aws-log-import-service/setup-aws-credentials.sh
```

## Traditional 

###	Install script below will install the system prerequisites, run with a user with administrative privileges.
```bash
/opt/fp-aws-log-import-service/deploy/install.sh
```
###	Run the commands below replacing the AWS-S3-File-Path part with the path of the Forcepoint S3 logs bucket. 

##### For PA

```bash
export FP_ENABLE_PA_SYNC=true
export PA_S3_URL=AWS-S3-File-Path
```
##### For CSG

```bash
export FP_ENABLE_CSG_SYNC=true
export CSG_S3_URL=AWS-S3-File-Path
```

###	The commands below are optional to run:  
Optional only applies for PA: it defaults to false if it’s not set, which will send Forcepoint logs for last 30 days and onwards, if that is the case then skip the command below, otherwise if you want to send Forcepoint logs starting from today and onwards, then run the command below.
```bash
export EXCLUDE_OLD_LOGS=true
```
Optional: it defaults to false (recommended) if it’s not set which will delete out of sync files between the bucket and the directory that would be any files older then 30 days in case of (Forcepoint Private Access), if that is the case then skip the command below, otherwise run the command below to keep the old files, note in this case you need to manage the storage capacity of those files.
```bash
export KEEP_OUT_OF_SYNC_FILES=true
```
###	Run the setup script with the command in the example below to install the program prerequisites and run it.
```bash
/opt/fp-aws-log-import-service/deploy/setup.sh
```

## Docker

```bash
docker build -t fp-aws-log-import-service . 
```

###	If you want to Forward Forcepoint logs for last 30 days and onwards, then run the command below, replacing AWS-S3-File-Path (Private Access):

```bash
docker run --detach \
   --env "PA_S3_URL=<AWS-S3-File-Path>"\
   --env "FP_ENABLE_PA_SYNC=true" \
   --name fp-pa-aws-log-import-service \
   --restart unless-stopped \
   --volume /opt/fp-aws-log-import-service/.aws:/root/.aws \
   --volume FpPaLogsVolume:/forcepoint-logs \
   --volume FpErrorLogsVolume:/app/fp-aws-log-import-service/logs \
   fp-aws-log-import-service
```

###	If you want to Forward Forcepoint logs starting from today and onwards, then run the command below, replacing AWS-S3-File-Path (Private Access):

```bash
docker run --detach \
   --env "PA_S3_URL=<AWS-S3-File-Path>"\
   --env "EXCLUDE_OLD_LOGS=true" \
   --env "FP_ENABLE_PA_SYNC=true" \
   --name fp-pa-aws-log-import-service \
   --restart unless-stopped \
   --volume /opt/fp-aws-log-import-service/.aws:/root/.aws \
   --volume FpPaLogsVolume:/forcepoint-logs \
   --volume FpErrorLogsVolume:/app/fp-aws-log-import-service/logs \
   fp-aws-log-import-service
```

###	Run the command below, replacing AWS-S3-File-Path (Cloud Security Gateway):

```bash
docker run --detach \
   --env "CSG_S3_URL=<AWS-S3-File-Path>"\
   --env "FP_ENABLE_CSG_SYNC=true" \
   --name fp-csg-aws-log-import-service \
   --restart unless-stopped \
   --volume /opt/fp-aws-log-import-service/.aws:/root/.aws \
   --volume FpCsgLogsVolume:/forcepoint-logs \
   --volume FpErrorLogsVolume:/app/fp-aws-log-import-service/logs \
   fp-aws-log-import-service
```

###	Run both (Private Access & Cloud Security Gateway):

```bash
docker run --detach \
   --env "FP_ENABLE_PA_SYNC=true" \
   --env "PA_S3_URL=<AWS-S3-File-Path>"\
   --env "FP_ENABLE_CSG_SYNC=true" \
   --env "CSG_S3_URL=<AWS-S3-File-Path>"\
   --name fp-aws-log-import-service \
   --restart unless-stopped \
   --volume /opt/fp-aws-log-import-service/.aws:/root/.aws \
   --volume FpLogsVolume:/forcepoint-logs \
   --volume FpErrorLogsVolume:/app/fp-aws-log-import-service/logs \
   fp-aws-log-import-service
```
