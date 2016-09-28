//
//  LinkProtocol.m
//  dd
//
//  Created by chenkai on 16/8/15.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "LinkProtocol.h"
#import "TxMwssage.h"
#import "BytesConverter.h"
#import "SAEncoder.h"
#import "OutObject.h"
@implementation LinkProtocol

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.SmallFrameSize = 50;
        self.BigFrameSize = 235;
        self.MaxCANPhyChannel = 4;
        self.CANParamCount = 6;
        self.WIFI_MODE = 98;
        self.FOURG_MODE = 99;
        self.FrameStart = 0x55;
        self.FrameEnd = 0xAA;
        self.CMD_CONTENT = 0x02;
        self.CMD_HEADER = 0x01;
        CmdId cmd = {0xFF,0x00,0x01,0x02,0x00,0x01,0x05,0xF0,0xF1,0x00,0x01,0x40,0x42,0x43,0x44,0x01,0x02,0x03,0x04,0x45,0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99};
        self.CmdId = cmd;
        
    }
    return self;
}

- (NSData *)getStopMsg:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Stop_CAN;
    frame.SequenceNum = sequenceNum;
    return [frame toBytes];
}
- (NSData *)getReadSNMsg:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Get_Version;
    Byte s = self.CmdId.SubCmd_Version_SN;
    [frame appendData:s];
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NEED;
    return [frame toBytes];
}

- (NSData *)getreadFirmwareMsg:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Get_Version;
    [frame appendData:self.CmdId.SubCmd_Version_SW];
    frame.ASK = ASK_NEED;
    frame.SequenceNum = sequenceNum;
    return [frame toBytes];
}

- (NSData *)getVCISeed:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.VCI_SA;
    frame.ASK = ASK_NEED;
    Byte s = self.CmdId.SubCmd_VCI_SA_GetSeed;
    [frame appendData:s];
    Byte u = self.CmdId.UNKNOWN;
    [frame appendData:u];
    [frame appendData:u];
    [frame appendData:u];
    [frame appendData:u];
    frame.SequenceNum = sequenceNum;
    return [frame toBytes];
}

-(NSData *)getVCIKey:(Byte)sequenceNum :(NSMutableData *)keyArray{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.VCI_SA;
    frame.ASK = ASK_NEED;
    Byte s = self.CmdId.SubCmd_VCT_SA_ValidateKey;
    [frame appendData:s];
    [frame appendDataWithData:keyArray];
    frame.SequenceNum = sequenceNum;
    return [frame toBytes];
}

- (NSData *)getOpenCanChannelMsg:(Byte)sequenceNum :(NSMutableArray<NSData *> *)chOptionList{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Start_CAN;
    frame.ASK = ASK_NEED;
    frame.SequenceNum = sequenceNum;
    for (NSData * data in chOptionList) {
        [frame appendDataWithData:(NSMutableData *)data];
       
    }
    return [frame toBytes];
}

- (NSData *)getVoltageMsg:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.ReadVoltage;
    frame.ASK = ASK_NEED;
    frame.SequenceNum = sequenceNum;
    return [frame toBytes];
}

- (NSData *)getModeMsg:(Byte)sequenceNum :(int)mode{
    TxMwssage *frame = [[TxMwssage alloc] init];
    if (mode == self.WIFI_MODE) {
        frame.CmdId = self.CmdId.To_WIFI_MOON;
    }
    if (mode == self.FOURG_MODE) {
        frame.CmdId = self.CmdId.To_4G_MODE;
    }
    frame.ASK = ASK_NO;
    frame.SequenceNum = sequenceNum;
    return [frame toBytes];
}

- (NSData *)getCloseCANChannelMsg:(Byte)sequenceNum :(NSData *)ch4Option{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Stop_CAN;
    frame.SequenceNum = sequenceNum;
    [frame appendDataWithData:(NSMutableData *)ch4Option];
    return [frame toBytes];
}

- (NSData *)getSAICSARequest:(Byte)sequenceNum :(long)VendorCode :(short)alg :(NSData *)seeds{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Compute_SAIC_SA;
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NEED;
    NSMutableData *tempArray = [[NSMutableData alloc] init];
    Byte *tempVendor = [[[BytesConverter alloc] init] longToBytes:VendorCode];
    NSData *temd = [NSData dataWithBytes:tempVendor length:sizeof(tempVendor)];
    for (int i = (int)temd.length - 5; i >=0; --i) {
        [tempArray appendBytes:&tempVendor[i] length:1];
    }
    Byte *tempAlg = [[[BytesConverter alloc] init] shortToBytes:alg];
    temd = [NSData dataWithBytes:tempAlg length:2];
    for (int i = (int)temd.length - 1; i >= 0; --i) {
        [tempArray appendBytes:&tempAlg[i] length:1];
    }
    [tempArray appendData:seeds];
    OutObject *obj = [[OutObject alloc] init];
    NSMutableData *encodeArray = [[NSMutableData alloc] init];
    [[[SAEncoder alloc] init] encode:tempArray :obj];
    encodeArray = obj.obj;
    [frame appendDataWithData:encodeArray];
    return  [frame toBytes];
}

- (void)encode:(NSMutableData *)src :(NSMutableData *)dest{
    Byte temp = 0xFF;
    if (src == nil || src.length == 0) {
        return;
    }
    Byte *bytes1 = (Byte *)[src bytes];
    Byte bytes2[src.length];
    
    
    int srcLen = (int)src.length;
    for (int i = 0; i < src.length; i++) {
        bytes2[srcLen - 1 - i] = bytes1[srcLen - 1 - i] ^ temp;
        temp = bytes2[srcLen - 1 - i];
    }
    [dest appendBytes:bytes2 length:sizeof(bytes2)];
}

- (NSData *)getStartKline:(Byte)sequenceNum :(int)baud{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Start_K;
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NEED;
    NSData *data = [NSData dataWithBytes:&baud length:sizeof(baud)];
    Byte *bytes = (Byte *)[data bytes];
    Byte byte[] = {bytes[3],bytes[2],bytes[1],bytes[0]};
    [frame appendDataWithData:[NSMutableData dataWithBytes:byte length:sizeof(byte)]];
    return [frame toBytes];
}

- (NSData *)getStopKLine:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Stop_K;
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NEED;
    
    return [frame toBytes];
}

- (NSData *)getStartBOSCH5_3Channel:(Byte)sequenceNum :(Byte)target{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Start_BOSCH5_3;
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NEED;
    [frame appendData:target];
     
    return [frame toBytes];
}


- (NSData *)getStopBOSCH5_3Channel:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.Stop_BOSCH5_3;
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NEED;
    return [frame toBytes];
}

- (NSData *)getHeartFrame:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.HeartFrame;
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NO;
    return  [frame toBytes];
}



- (NSData *)getRestoreFirmwareFrame:(Byte)sequenceNum{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = self.CmdId.SetFirmware;
    frame.SequenceNum = sequenceNum;
    frame.ASK = ASK_NO;
    Byte s = self.CmdId.SubCmd_SetFirmware_Default;
    [frame appendData:s];
    
    return [frame toBytes];
}

- (Byte)calcChecksum:(NSData *)bufData :(int)startIdx :(int)len{
    short cs = 0;
    Byte *buf = (Byte *)[bufData bytes];
    for (int i = startIdx; i < startIdx + len; ++i) {
        cs += buf[i];
        cs = (short)((cs + (cs >> 8)) & (short)0xff);
        
    }
    return (Byte) ~cs;
}



@end
