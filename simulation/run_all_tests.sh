#!/bin/bash
echo run tests
echo


cd test0_fcl
echo "test0_fcl"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..


cd test1_ifu
echo "test1_ifu"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..


cd test2_iq
echo "test2_iq"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..


cd test3_ifu_dataflow
echo "test3_ifu_data_flow"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..


cd test4_dec
echo "test4_dec"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..


cd test5_ifu_flush_stall
echo "test5_ifu_flush_stall"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..
