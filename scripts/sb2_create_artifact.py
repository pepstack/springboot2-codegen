#!/usr/bin/python
#-*- coding: UTF-8 -*-
#
# @file: sb2_create_artifact.py
#
#   创建新产品
#
# @version: 2018-06-05 18:08:36
# @create: 2018-06-05 18:08:36
# @update: 2018-06-05 18:08:36
#
#######################################################################
import os

# import your local modules
import utils.utility as util
import utils.evntlog as elog

#######################################################################

# 创建新产品
def create_artifact(**kwargs):
    print "artifactRoot=", kwargs['artifactRoot']
    print "artifactId=", kwargs['artifactId']
    print "artifactName=", kwargs['artifactName']
    pass