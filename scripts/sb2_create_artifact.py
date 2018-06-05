#!/usr/bin/python
#-*- coding: UTF-8 -*-
#
# @file:
#
#   创建新产品
#
# @version: 0.0.1
# @create: $create$
# @update:
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