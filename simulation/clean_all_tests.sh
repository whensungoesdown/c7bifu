#!/bin/bash
echo clean tests
echo

cd test0_fcl
echo "test0_fcl"
./clean.sh
echo ""
cd ..


cd test1_ifu
echo "test1_ifu"
./clean.sh
echo ""
cd ..


cd test2_iq
echo "test2_iq"
./clean.sh
echo ""
cd ..


cd test3_ifu_dataflow
echo "test3_ifu_dataflow"
./clean.sh
echo ""
cd ..


cd test4_dec
echo "test4_dec"
./clean.sh
echo ""
cd ..


cd test5_ifu_flush_stall
echo "test5_ifu_flush_stall"
./clean.sh
echo ""
cd ..
