// -*- groovy -*-
HTTP_PROXY = "http://www-proxy.otp.ericsson.se:8080"
HTTPS_PROXY = "http://www-proxy.otp.ericsson.se:8080"
NO_PROXY = "localhost,127.0.0.1,.otp.ericsson.se,otp.ericsson.se,otp,erlang,support,nessie,wiki,monitor,jenkins"

DOCKER_ARGS = "--ulimit core=-1 --ulimit nofile=1000000:1000000 "
DOCKER_RUN_ARGS = "--volume=\"/home/otptest/bin/:/home/otptest/bin/:rw\" " +
    "--volume=\"/home/otp/bin:/home/otp/bin:rw\" " +
    "--security-opt seccomp=unconfined --cap-add=SYS_PTRACE ${DOCKER_ARGS} "
DOCKER_BUILD_ARGS = "${DOCKER_ARGS} " +
    "--build-arg MAKEFLAGS=-j16 " +
    "--build-arg https_proxy=${HTTP_PROXY} " +
    "--build-arg http_proxy=${HTTP_PROXY} " +
    "--build-arg HTTP_PROXY=${HTTP_PROXY} " +
    "--build-arg HTTPS_PROXY=${HTTP_PROXY} " +
    "--build-arg NO_PROXY=${NO_PROXY} " +
    "--build-arg no_proxy=${NO_PROXY} scripts"

DOCKER_INSIDE_ARGS = "${DOCKER_RUN_ARGS} --entrypoint=\"\" "

timestamp = ""
sha = ""
DOCKER_REGISTRY = "apollo.otp.ericsson.se:5000/"

FAST_BUILD = false

otp = Collections.synchronizedMap([:]);

/*
 We use a scripted pipeline instead of a declarative pipeline here
 as we want to do parallel execution of dynamic stages (i386 vs i686)
 */
pipeline {

    options {
        // Limit pipeline to only one build per branch at the same time
        disableConcurrentBuilds();
        timestamps();
        buildDiscarder(logRotator(numToKeepStr: '50'));
    }

    agent { label 'docker' }

    stages {
        stage('pack') { steps { script {

            timestamp = sh([script: 'date "+%Y-%m-%d_%H"', returnStdout: true]).trim()
            sh 'git archive --format=tar.gz --prefix=otp_src/ -o scripts/otp_src.tar.gz HEAD'
            sha = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
            stash name: "scripts", includes: "scripts/"
        } } }
        stage('build') {
            parallel {
                stage("64-bit") {
                    options { timeout(time: 30, unit: 'MINUTES'); }
                    steps { script {
                        buildDockerImage(64)
                    } }
                }
                stage("32-bit") {
                    options { timeout(time: 30, unit: 'MINUTES'); }
                    agent { label 'docker '}
                    steps { script {
                        buildDockerImage(32)
                    } }
                }
            }
        }
        stage('check') {
            options { timeout(time: 30, unit: 'MINUTES'); }
            parallel {
                stage('vxworks') { steps { script { dockReg {
                    def targets = ["simlinux" : "i586-wrs-vxworks",
                                   "ppc32" : "powerpc-wrs-vxworks"];
                    targets.each { target, triple ->
                        otp[32].inside(DOCKER_INSIDE_ARGS +
                                       " -v \"/net/duper/export/extra/vxworks/WindRiver:/WindRiver\"")
                        {
                            sh "cd \$ERL_TOP && \$ERL_TOP/scripts/build-otp-vxworks ${target} ${triple}"
                        }
                    }
                } } } }
                stage('build special types') { steps { script { dockReg {
                    otp.each { arch, img ->
                        stage("${arch}") {
                            img.inside(DOCKER_INSIDE_ARGS) {
                                sh '''
if [ -f $ERL_TOP/erts/emulator/utils/beam_emu_vars ];
then
    cd $ERL_TOP/erts/emulator
    make -f x86_64-unknown-linux-gnu/Makefile PROFILE=use check_emu_registers
    cd $ERL_TOP
fi'''
                            }
                            special = docker.build(
                                "${getPrefix(arch)}otp-run-tests-special-${BRANCH_NAME}:${BUILD_ID}",
                                "-f scripts/Dockerfile.special " +
                                    "--build-arg \"BASE_IMAGE=${DOCKER_REGISTRY}${getPrefix(arch)}otp-run-tests-${BRANCH_NAME}:${BUILD_ID}\" " +
                                    "${DOCKER_BUILD_ARGS}"
                            );
                            special.push("latest");
                            special.push(BUILD_ID);
                        }
                    }
                } } } }
                stage('check tests') { steps { script { dockReg {
                    otp[64].inside(DOCKER_INSIDE_ARGS) {
                        sh 'erl -s init stop'
		        sh "mkdir /daily_build/test && \$ERL_TOP/otp_build tests /daily_build/test"
                        def applications = sh([script: 'ls -d /daily_build/test/*_test/',
                                               returnStdout: true]).trim().split('[\\r\\n ]+')
                        for (int i = 0; i < applications.size(); i++) {
                            sh "\$ERL_TOP/scripts/build-otp-tests ${applications[i]}"
                        }
                    }
                } } } }
                stage('check docs') { steps { script { dockReg {
                    if (!FAST_BUILD) {
                        def anchorIssues
                        otp[64].inside(DOCKER_INSIDE_ARGS) {
                            sh script: 'cd $ERL_TOP && make release_docs', label: "release_docs"
                            sh '(cd $ERL_TOP/system/doc/ && make release_docs TESTROOT=$TARGET_DIR INSTALLROOT=$TARGET_DIR)'
                            sh script: 'cd $ERL_TOP && $ERL_TOP/scripts/run-xml-lint', label: "xmllint"
                            sh script: '''#!/bin/bash
set -o pipefail
cd $ERL_TOP/release/`erts/autoconf/config.guess`/
/home/otp/bin/otp_html_check `pwd` doc/index.html erts-*/doc/index.html lib/*/doc/index.html | tee $WORKSPACE/otp_html_check.log
''', label: "html check"
                            sh script: '''#!/bin/bash
set -o pipefail
cd $install_dir
./Install -minimal `pwd` | tee $WORKSPACE/otp_man_check.log
'''
                            recordIssues sourceCodeEncoding: 'UTF-8',
                                tool: groovyScript(parserId: 'otp_html_check_anchors',
                                                   pattern:'**/*otp_html_check.log')
                            recordIssues sourceCodeEncoding: 'UTF-8',
                                tool: groovyScript(parserId: 'otp_html_check_links',
                                                   pattern:'**/*otp_html_check.log')
                            recordIssues sourceCodeEncoding: 'UTF-8',
                                tool: groovyScript(parserId: 'otp_man_check',
                                                   pattern:'**/*otp_man_check.log')

                        }
                    }
                } } } }
                stage('run dialyzer') { steps { script { dockReg {
                    if (!FAST_BUILD) {
                        otp[64].inside(DOCKER_INSIDE_ARGS) {
                            sh '''#!/bin/bash
set -o pipefail
cd $ERL_TOP
if [ -f $ERL_TOP/scripts/run-dialyzer ]; then
    $ERL_TOP/scripts/run-dialyzer | tee $WORKSPACE/otp_dialyzer.log
fi
'''
                        }
                    }
                } } } }
                stage('benchmark') {
		    steps {
                        script {
                            dockReg {
                                otp[64].inside(DOCKER_INSIDE_ARGS) {
                                    OTP_VSN = sh([script: 'cat \$ERL_TOP/OTP_VERSION | sed "s|^\\([0-9]*\\)\\..*|\\1|"',
                                                  returnStdout: true]).trim().toInteger();
                                }
                            }
                            if (OTP_VSN > 20) {
                                build job: "/benchmark",
                                    propagate: false, wait: false,
                                    parameters: [[$class: 'StringParameterValue', name: 'IMAGE_BRANCH', value: BRANCH_NAME]]
                            }
                        }
                    }
		}
                stage('windows') {
		    steps {
                        build job: "/windows/${BRANCH_NAME}", propagate: false,
                            wait: false, parameters: []
                    }
		}
            }
        }
    }
    post {
        success {
            recordIssues enabledForFailure: true, tools: [gcc4()],
                filters: [includeFile('.*\\.[cho]:?[0-9]*')]
            recordIssues enabledForFailure: true, tools: [erlc()],
                filters: [includeFile('.*\\.[he]rl:?[0-9]*')]
        }
        unsuccessful {
            /* See apollo:/ldisk/lukas/jenkins-data/email-templates/ for the template */
            emailext subject: '${DEFAULT_SUBJECT}',
                body: '${SCRIPT, template="pack-and-build.template"}',
                to: 'lukas@erlang.org',
                recipientProviders: [[$class: 'CulpritsRecipientProvider']],
                presendScript: '${DEFAULT_PRESEND_SCRIPT}'
        }
    }
}

def buildDockerImage(arch) {
    dockReg {

        unstash "scripts";

        def img = docker.build(
            "${getPrefix(arch)}otp-src-${BRANCH_NAME}",
            "-f scripts/Dockerfile.pack-otp --pull " +
                "--build-arg \"FAST_BUILD=${FAST_BUILD}\" " +
                "--build-arg \"BUILD_ID=${BUILD_ID}\" " +
                "--build-arg \"BRANCH=${BRANCH_NAME}\" " +
                "--build-arg \"TIMESTAMP=${timestamp}\" " +
                "--build-arg \"SHA=${sha}\" " +
                "--build-arg \"BASE=${getPrefix(arch)}ubuntu:16.04\" " +
                DOCKER_BUILD_ARGS);
        img.push("latest");
        img.push(BUILD_ID);

        // Because of how img.inspect works the img needs to be the
        // build_id tagged image. See
        // https://github.com/jenkinsci/docker-workflow-plugin/blob/master/src/main/resources/org/jenkinsci/plugins/docker/workflow/Docker.groovy#L124-L126
        img = docker.build(
            "${getPrefix(arch)}otp-run-tests-${BRANCH_NAME}:${BUILD_ID}",
            "-f scripts/Dockerfile.run-tests " +
                "--build-arg \"FAST_BUILD=${arch == 32 ? true : FAST_BUILD}\" " +
                "--build-arg \"BASE_IMAGE=${DOCKER_REGISTRY}${getPrefix(arch)}otp-src-${BRANCH_NAME}:${BUILD_ID}\" " +
                "${DOCKER_BUILD_ARGS}");

        img.push("latest");
        img.push(BUILD_ID);
        otp[arch] = img;
    }
}

def getPrefix(arch) {
    return arch == 64 ? "" : "i386/";
}

def dockReg(body) {
    docker.withRegistry("http://" + DOCKER_REGISTRY) {
        body();
    }
}
