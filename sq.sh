#!/bin/bash

# Define the job queue file and log file
JOB_QUEUE_FILE="job_queue.txt"
LOG_FILE="job_queue_log.txt"
PROCESSING_FLAG="processing.flag"

# Function to add a job to the queue
add_job() {
    echo "$1" >> "$JOB_QUEUE_FILE"
    echo "Job added to the queue: $1"
    
    # Check if the processing flag is set
    if [ ! -f "$PROCESSING_FLAG" ]; then
        # If the flag is not set, call process_queue function in the background
        process_queue &
        touch "$PROCESSING_FLAG"
    fi
}

# Function to log messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to process the job queue
process_queue() {
    while true; do
        # Check if there are any jobs in the queue
        if [ -s "$JOB_QUEUE_FILE" ]; then
            # Read and process the first job
            local job=$(head -n 1 "$JOB_QUEUE_FILE")
            log_message "Processing job: $job"
            
            # Execute the job (replace this line with your actual job processing logic)
            eval "$job"

            # Check the exit status of the job
            if [ $? -eq 0 ]; then
                log_message "Job successfully processed: $job"
            else
                log_message "Error processing job: $job"
            fi

            # Remove the processed job from the queue
            tail -n +2 "$JOB_QUEUE_FILE" > "$JOB_QUEUE_FILE.tmp" && mv "$JOB_QUEUE_FILE.tmp" "$JOB_QUEUE_FILE"
        else
            # If no jobs in the queue, remove the processing flag and exit the loop
            log_message "No jobs in the queue. Exiting."
            rm -f "$PROCESSING_FLAG"
            break
        fi
    done
}

# Example usage:
add_job "echo 'Hello, World!'"
add_job "ls -l"
add_job "date"

# Simulate adding more jobs from the console
add_job "echo 'New job added from console'"
add_job "echo 'Another new job from console'"

# Add a delay to simulate the script running for a while
sleep 3

# Add more jobs from the console
add_job "echo 'Yet another new job from console'"
add_job "echo 'And one more from console'"
