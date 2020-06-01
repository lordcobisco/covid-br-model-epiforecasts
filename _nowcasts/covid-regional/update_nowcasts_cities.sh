#!/bin/bash

## Update shared delay
#Rscript update_delay.R

## Load shared delay from github
Rscript load_delay.R

## Run regions in parallel
#Rscript germany/update_nowcasts.R & 
#Rscript italy/update_nowcasts.R &
#Rscript united-kingdom/update_nowcasts.R &
#wait

#Rscript united-states/update_nowcasts.R &
Rscript brazil/update_nowcasts_cities.R &
#Rscript india/update_nowcasts.R &
wait

