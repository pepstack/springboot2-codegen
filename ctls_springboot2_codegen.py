#!/usr/bin/python
#-*- coding: UTF-8 -*-
#
# @file:
#
#   自动生成 springboot2.0 代码的脚本
#
# @version: 0.0.1
# @create: $create$
# @update:
#
#######################################################################
import os, sys, stat, signal, shutil, inspect, commands, time, datetime

import optparse, ConfigParser

#######################################################################
# application specific
APPFILE = os.path.realpath(sys.argv[0])
APPPATH = os.path.dirname(APPFILE)
APPNAME,_ = os.path.splitext(os.path.basename(APPFILE))
APPVER = "0.0.1"
APPHELP = "Automatically generating code for spring boot2 web project."


# import your local modules
import utils.utility as util
import utils.evntlog as elog
#######################################################################

from scripts.sb2_create_artifact import create_artifact


#######################################################################
# main entry function
#
def main(parser):
    (options, args) = parser.parse_args(args=None, values=None)

    # 当前脚本绝对路径
    abspath = util.script_abspath(inspect.currentframe())

    # 产品文件夹全路径
    artifactRoot = options.artifactRoot
    
    # 产品文件夹名称
    artifactRootName = os.path.basename(artifactRoot)

    artifactId = options.artifactId
    if not artifactId:
        artifactId = artifactRootName

    artifactName = options.artifactName
    if not artifactName:
        artifactName = artifactId

    if not options.groupId:
        exit(-1)

    if artifactRootName != artifactId:
        print "WARN:", "产品ID与文件夹名称不一致, 可能导致歧义:"
        print "产品文件夹:", artifactRoot
        print "产品ID:", artifactId
        print "期望的产品ID:", artifactRootName
        pass

    # 解压模板文件
    demoZipfile = os.path.join(abspath, "demo.zip")
    if not util.file_exists(demoZipfile):
        print "ERROR 模板文件不存在", demoZipfile
        exit(-1)

    demoRootDir = os.path.join(abspath, "build", "tmp", "demo")
    if util.dir_exists(demoRootDir):
        shutil.rmtree(demoRootDir)
        pass

    util.unzip_file(demoZipfile, demoRootDir)
    if not util.dir_exists(demoRootDir):
        print "ERROR 模板路径不存在", demoRootDir
        exit(-1)

    if not options.forceUpdate:
        create_artifact(
            artifactRoot = artifactRoot,
            artifactId = artifactId, 
            artifactName = artifactName, 
            groupId = options.groupId,
            artifactVersion = options.artifactVersion,
            springbootVersion = options.springbootVersion,
            javaVersion = options.javaVersion,
            description = options.description,
            author = options.author)
    else:
        print "当前不支持!"
        pass

    # 使用完毕删除模板
    shutil.rmtree(demoRootDir)
    pass


#######################################################################
# Usage:
#
#   $ ./ctls_springboot2_codegen.py -P /path/to/artifact
#
#
if __name__ == "__main__":
    parser, group, optparse = util.use_parser_group(APPNAME, APPVER, APPHELP,
        '%prog [Options]')

    # 产品默认名称
    artifactNameDefault = "demo"

    # 产品根目录
    artifactRootDefault = os.path.join(APPPATH, "build", artifactNameDefault)

    # 读取默认的 java 版本
    javaVersionDefault = util.read_first_line_nothrow(os.path.join(APPPATH, "JAVA.VERSION"))
    
    # 读取默认的 springboot 版本
    springbootVersionDefault = util.read_first_line_nothrow(os.path.join(APPPATH, "SPRINGBOOT.VERSION"))

    # 以下选项用于生成 pom.xml
    #
    group.add_option("--artifact-root",
        action="store", dest="artifactRoot", type="string", default=artifactRootDefault,
        help="指定产品的文件夹名. 新建产品的文件夹必须为空, 否则不能创建产品. 默认为: " + artifactRootDefault,
        metavar="artifactRoot")

    group.add_option("--artifact-name",
        action="store", dest="artifactName", type="string", default=None,
        help="指定产品的名称. 默认根据 artifactRoot 自动获取",
        metavar="artifactName")

    group.add_option("--group-id",
        action="store", dest="groupId", type="string", default="com.pepstack",
        help="指定产品组ID (默认: com.pepstack)",
        metavar="groupId")

    group.add_option("--artifact-id",
        action="store", dest="artifactId", type="string", default=None,
        help="指定产品ID. 默认根据 artifactRoot 自动获取",
        metavar="artifactId")

    group.add_option("--artifact-version",
        action="store", dest="artifactVersion", type="string", default="0.0.1-SNAPSHOT",
        help="指定产品版本 (默认: 0.0.1-SNAPSHOT)",
        metavar="version")

    group.add_option("--description",
        action="store", dest="description", type="string", default="spring boot 2 web project",
        help="指定产品描述",
        metavar="description")

    group.add_option("--springboot-version",
        action="store", dest="springbootVersion", type="string", default=springbootVersionDefault,
        help="指定使用的 springboot 版本 (默认: " + springbootVersionDefault,
        metavar="springboot.version")

    group.add_option("--java-version",
        action="store", dest="javaVersion", type="string", default=javaVersionDefault,
        help="指定使用的 java 版本 (默认: " + javaVersionDefault,
        metavar="java.version")

    group.add_option("--author",
        action="store", dest="author", type="string", default="master@pepstack.com",
        help="指定产品作者 (默认: master@pepstack.com)",
        metavar="author")

    group.add_option("--force-update",
        action="store_true", dest="forceUpdate", default=False,
        help="是否强制更新产品配置 (默认: 否)")

    main(parser)

    sys.exit(0)
