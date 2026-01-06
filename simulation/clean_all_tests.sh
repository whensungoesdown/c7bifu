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
