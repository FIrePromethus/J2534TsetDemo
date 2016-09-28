//
//  LinkProtocol.h
//  dd
//
//  Created by chenkai on 16/8/15.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(Byte,ACK){
    ASK_NO = 0x00,
    ASK_NEED = 0x01
};

typedef struct CmdId{
    Byte UNKNOWN;
    Byte Start_CAN;//初始化CAN
    Byte Stop_CAN;//关闭CAN
    Byte VCI_SA;//unlock VCI
    Byte SubCmd_VCI_SA_GetSeed;
    Byte SubCmd_VCT_SA_ValidateKey;//sub cmd
    Byte HeartFrame;
    Byte ProgramCmd;
    Byte SetFirmware;
    Byte SubCmd_SetFirmware_Default;
    Byte SubCmd_SetFirmware_New;
    Byte Assign_CANPins;
    Byte ReadVoltage;
    Byte Set_Version;
    Byte Get_Version;
    Byte SubCmd_Version_SN;
    Byte SubCmd_Version_SSID;
    Byte SubCmd_Version_SW;
    Byte SubCmd_Version_HW;
    Byte Compute_SAIC_SA;
    Byte RequestDataBySN;
    Byte Set_ISO15765_Param;
    Byte Send_ISO15765_Frame;
    Byte Send_CAN_Frame;
    Byte Del_ISO15765_Channel;
    Byte Set_CAN_Padding;
    Byte Enable_Cycle_Frame;
    Byte Start_K;
    Byte Stop_K;
    Byte Set_K_Param;
    Byte Send_K_Frame;
    Byte FastInit_K;
    
    Byte Start_BOSCH5_3;
    Byte Stop_BOSCH5_3;
    Byte Send_BOSCH5_3;
    
    Byte To_WIFI_MOON;
    Byte To_4G_MODE;
    
}CmdId;

@interface LinkProtocol : NSObject

@property(nonatomic,assign) int SmallFrameSize;
@property(nonatomic,assign) int BigFrameSize;
@property(nonatomic,assign) int MaxCANPhyChannel;
@property(nonatomic,assign) int CANParamCount;
@property(nonatomic,assign) int WIFI_MODE;
@property(nonatomic,assign) int FOURG_MODE;
@property(nonatomic,assign) Byte FrameStart;
@property(nonatomic,assign) Byte FrameEnd;
@property(nonatomic,assign) Byte CMD_HEADER;//命令头
@property(nonatomic,assign) Byte CMD_CONTENT;//命令内容
@property(nonatomic,assign) ACK ACK;
@property(nonatomic,assign) CmdId CmdId;

- (NSData *)getStopMsg:(Byte)sequenceNum;

- (NSData *)getReadSNMsg:(Byte)sequenceNum;

- (NSData *)getreadFirmwareMsg:(Byte)sequenceNum;

- (NSData *)getVCISeed:(Byte)sequenceNum;

- (NSData *)getVCIKey:(Byte)sequenceNum :(NSMutableData *)keyArray;

- (NSData *)getOpenCanChannelMsg:(Byte)sequenceNum :(NSMutableArray<NSData *> *)chOptionList;

- (NSData *)getVoltageMsg:(Byte)sequenceNum;

- (NSData *)getModeMsg:(Byte)sequenceNum :(int)mode;

- (NSData *)getCloseCANChannelMsg:(Byte)sequenceNum :(NSData *)ch4Option;

- (NSData *)getSAICSARequest:(Byte)sequenceNum :(long)VendorCode :(short)alg :(NSData *)seeds;

- (NSData *)getStartKline:(Byte)sequenceNum :(int)baud;

- (NSData *)getStopKLine:(Byte)sequenceNum;

- (NSData *)getStartBOSCH5_3Channel:(Byte)sequenceNum :(Byte)target;

- (NSData *)getStopBOSCH5_3Channel:(Byte)sequenceNum;

- (NSData *)getHeartFrame:(Byte)sequenceNum;

- (NSData *)getRestoreFirmwareFrame:(Byte)sequenceNum;

- (Byte)calcChecksum:(NSData *)buf :(int)startIdx :(int)len;

@end
