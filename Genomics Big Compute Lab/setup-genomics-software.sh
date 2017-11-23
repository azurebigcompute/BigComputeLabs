#!/bin/bash
####
#### Karl Podesta <kapodest@microsoft.com> - Feb 2nd 2017
#### Genomics Software Stack Installation - CentOS 7.3
####

### Install Pre-requisite Linux/OS software
yum -y install java-1.8.0-openjdk-devel ncurses-devel gcc zlib-devel autoreconf autoconf automake g++ gcc-c++

### Download software
mkdir /opt/genomics
mkdir ~/genomics-software
cd ~/genomics-software
wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
wget https://github.com/samtools/bcftools/releases/download/1.3.1/bcftools-1.3.1.tar.bz2
wget https://github.com/samtools/htslib/releases/download/1.3.2/htslib-1.3.2.tar.bz2
wget https://github.com/vcftools/vcftools/tarball/master
wget https://github.com/broadinstitute/picard/releases/download/2.8.2/picard-2.8.2.jar
wget http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip
wget http://www.openbioinformatics.org/annovar/download/0wgxR2rIVP/annovar.latest.tar.gz
##### **** NEED TO ALSO DOWNLOAD BWA and GATK - separately

### Install htslib
cd ~/genomics-software
bzip2 -d htslib-1.3.2.tar.bz2
tar xvf htslib-1.3.2.tar
cd htslib-1.3.2/
./configure --prefix=/opt/genomics
make
make install

### Install samtools
cd ~/genomics-software
bzip2 -d samtools-1.3.1.tar.bz2
tar xvf samtools-1.3.1.tar
cd samtools-1.3.1/
./configure --prefix=/opt/genomics --with-htslib=/opt/genomics
make
make install

### Install bcftools
cd ~/genomics-software
bzip2 -d bcftools-1.3.1.tar.bz2
tar xvf bcftools-1.3.1.tar
cd bcftools-1.3.1/
make prefix=/opt/genomics
make prefix=/opt/genomics install

### Install vcftools
cd ~/genomics-software
mv master vcftools.tar.gz
gzip -d vcftools.tar.gz
tar xvf vcftools.tar
cd vcftools-vcftools*/
./autogen.sh
./configure --prefix=/opt/genomics/
make
make install

### Install picard
cp ~/genomics-software/picard-2.8.2.jar /opt/genomics/bin

### Install snpEff
cd ~/genomics-software
unzip snpEff_latest_core.zip
cp -rp snpEff/*.jar /opt/genomics/bin

### Install GATK
cd ~/genomics-software
bzip2 -d GenomeAnalysisTK-3.7.tar.bz2
tar xvf GenomeAnalysisTK-3.7.tar
cp GenomeAnalysisTK.jar /opt/genomics/bin

### Install BWA
cd ~/genomics-software
bzip2 -d bwa-0.7.15.tar.bz2
tar xvf bwa-0.7.15.tar
cd bwa-0.7.15/
make
cp bwa /opt/genomics/bin/

### Install ANNOVAR
cd ~/genomics-software
tar xzvf annovar.latest.tar.gz
cp -rp annovar /opt/genomics
