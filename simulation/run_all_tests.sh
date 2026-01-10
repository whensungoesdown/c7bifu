#!/bin/bash
echo run tests
echo

cd test0_fcl
echo "test0_fcl"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test1_ifu
echo "test1_ifu"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test2_iq
echo "test2_iq"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test3_ifu_dataflow
echo "test3_ifu_dataflow"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test4_dec
echo "test4_dec"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


cd test5_ifu_flush_stall
echo "test5_ifu_flush_stall"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..
