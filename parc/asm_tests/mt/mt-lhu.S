//========================================================================
// mt-lhu
//========================================================================

#include "mt-macros.h"

    TEST_MT_BEGIN

    //--------------------------------------------------------------------
    // Basic tests
    //--------------------------------------------------------------------

    TEST_LD_OP( lhu, 0, tdata_0, 0x00001001 )
    TEST_LD_OP( lhu, 2, tdata_0, 0x00002002 )
    TEST_LD_OP( lhu, 4, tdata_0, 0x00003003 )
    TEST_LD_OP( lhu, 6, tdata_0, 0x00004004 )

    // Test no sign extension

    TEST_LD_OP( lhu, 0, tdata_7, 0x00008101 )
    TEST_LD_OP( lhu, 2, tdata_7, 0x00008202 )
    TEST_LD_OP( lhu, 4, tdata_7, 0x00008303 )
    TEST_LD_OP( lhu, 6, tdata_7, 0x0000ffff )

    // Test with negative offset

    TEST_LD_OP( lhu, -6, tdata_3, 0x00001001 )
    TEST_LD_OP( lhu, -4, tdata_3, 0x00002002 )
    TEST_LD_OP( lhu, -2, tdata_3, 0x00003003 )
    TEST_LD_OP( lhu,  0, tdata_3, 0x00004004 )

    // Test with a negative base

    la    $2, tdata_0
    addiu $2, $2, -32
    lh    $4, 32($2)
    TEST_CHECK_EQ( $4, 0x00001001 )

    // Test with unaligned base

    la    $2, tdata_0
    addiu $2, $2, -3
    lhu   $4, 5($2)
    TEST_CHECK_EQ( $4, 0x00002002 )

    //--------------------------------------------------------------------
    // Bypassing tests
    //--------------------------------------------------------------------

    TEST_LD_DEST_BYP( 0, lhu, 2, tdata_1, 0x00003003 )
    TEST_LD_DEST_BYP( 1, lhu, 2, tdata_2, 0x00004004 )
    TEST_LD_DEST_BYP( 2, lhu, 2, tdata_3, 0x00005005 )
    TEST_LD_DEST_BYP( 3, lhu, 2, tdata_4, 0x00006006 )
    TEST_LD_DEST_BYP( 4, lhu, 2, tdata_5, 0x00007007 )

    TEST_LD_SRC0_BYP( 0, lhu, 2, tdata_1, 0x00003003 )
    TEST_LD_SRC0_BYP( 1, lhu, 2, tdata_2, 0x00004004 )
    TEST_LD_SRC0_BYP( 2, lhu, 2, tdata_3, 0x00005005 )
    TEST_LD_SRC0_BYP( 3, lhu, 2, tdata_4, 0x00006006 )
    TEST_LD_SRC0_BYP( 4, lhu, 2, tdata_5, 0x00007007 )

    //--------------------------------------------------------------------
    // Test write-after-write hazard
    //--------------------------------------------------------------------

    la  $4, tdata_0
    lhu $3, 0($4)
    li  $3, 2
    TEST_CHECK_EQ( $3, 2 )

    la  $5, tdata_0
    lhu $6, 0($5)
    nop
    li  $6, 2
    TEST_CHECK_EQ( $6, 2 )

    TEST_MT_END

    //--------------------------------------------------------------------
    // Test data
    //--------------------------------------------------------------------

    .data
    .align 2

tdata_0:  .hword 0x1001
tdata_1:  .hword 0x2002
tdata_2:  .hword 0x3003
tdata_3:  .hword 0x4004
tdata_4:  .hword 0x5005
tdata_5:  .hword 0x6006
tdata_6:  .hword 0x7007
tdata_7:  .hword 0x8101
tdata_8:  .hword 0x8202
tdata_9:  .hword 0x8303
tdata_11: .hword 0xffff

