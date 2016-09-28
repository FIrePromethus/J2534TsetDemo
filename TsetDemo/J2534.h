//
//  J2534.h
//  J2534
//
//  Created by chenkai on 16/8/11.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Device, PassThruMsg,OutObject;

typedef NS_ENUM(NSInteger, EpassThruResult) {
    STATUS_NOERROR = 0,
    ERR_DEVICE_NOT_CONNECTED,
    ERR_DEIVICE_IN_USE,
    ERR_NULL_PARAMETER,
    ERR_INVALLD_DEVICE_ID,
    ERR_FALLED,
    ERR_BUFFER_EMPTY,
    ERR_TLMEOUT,
    ERR_CHANNEL_IN_USE,
    ERR_NOT_SUPPORTED,
    ERR_INVALLD_CHANNEL_ID,
    ERR_INVALID_TIME_INTERVAL,
    ERR_INVALID_MSG,
    ERR_MSG_PROTOCOL_ID,
    ERR_INVALID_FLLTER_ID,
    ERR_NOT_UNIQUE,
    ERR_EXCEEDED_LIMIT,
    ERR_NO_FLOW_CONTROL,
    ERR_PIN_INVALLD,
    ERR_INVALLD_IOCTL_VALUE,
    ERR_INVALLD_MSG_ID,
    ERR_NOTIMPLEMENTED
    
};
typedef NS_ENUM(NSInteger, EPassThruParams) {
    DATA_RATE = 0x01,
    LOOPBACK = 0x03,
    P1_MAX = 0x07,
    P3_MIN = 0x0A,
    P4_MIN = 0x0C,
    TIDLE = 0x13,
    TINIL = 0x14,
    TWUP = 0x15,
    PARITY = 0x16,
    J1962_PINS = 0x8001
};

typedef NS_ENUM(NSInteger, EProtocolId) {
    Unknown = 0x00,
    ISO14230 = 0x04,
    CAN = 0x05,
    ISO15765 = 0X06,
    CAN_PS = 0x8004,
    ISO15765_PS = 0x8005,
    BOSCH5_3 = 0x800A
};
typedef NS_ENUM(NSInteger, EFilterType){
    Pass = 1,
    Block = 2,
    FlowControl = 3,
};

typedef NS_ENUM(NSInteger,EIoctlId){
    GET_CONFIG = 0x01,
    SET_CONFIG = 0x02,
    READ_VBATT = 0x03,
    FIVE_BAUD_INIT = 0x40,
    FAST_INIT = 0x05,
    CLEAR_RX_BUFFER= 0x08,
    CLEAR_PERLOPDIC_MSGS = 0x09,
    CLEAR_MSG_FILTERS =0x0A,
    GET_DEVIGE_SN = 0x10000,
    CHANGE_TO_4G_MODE = 0x10002,
    CHANGE_TO_WIFI_MODE = 0x10002
    
};
@interface J2534 : NSObject
@property (nonatomic, strong) Device *device;
@property (nonatomic,assign) long vendorId;
@property (nonatomic, copy) NSString *TAG;
@property (nonatomic) BOOL isEnableTrace;

- (EpassThruResult)PassThruOpen:(NSString *)name :(OutObject *)outDeviceId;


- (EpassThruResult)PassThruClose:(int)deviceId;

- (EpassThruResult)PassThruConnect:(int)deviceId :(EProtocolId)protocolId :(unsigned long)flags :(unsigned long)bauRate :(OutObject *)outChannelId;

- (EpassThruResult)PassThruDisconnect:(int)channelId;

- (EpassThruResult)PassThruReadMsgs:(int)channelId :(OutObject *)outMsgArray :(OutObject *)inOutNum :(int)timeOut;

- (EpassThruResult)PassThruWriteMsgs:(int)channelId :(NSMutableArray<PassThruMsg *> *)inMsgArray :(OutObject *)outNum :(int)timeOut;

- (EpassThruResult)PassThruStartPeriodicMsg:(int)channelId :(PassThruMsg *)inMsg :(OutObject *)outPeriodicId :(int)timeInterval;

- (EpassThruResult)PassThruStopPeriodicMsg:(int)channelId :(int)periodicId;

- (EpassThruResult)PassThruStartMsgFilter:(int)channelId :(EFilterType)filterType :(PassThruMsg *)maskMsg :(PassThruMsg *)paterrMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterId;

- (EpassThruResult)PassThruStopMsgFilter:(int)channelId :(int)filterId;

- (EpassThruResult)PassThruReadVersion:(int)deviceId :(OutObject *)firmwareVersion :(OutObject *)jarVersion :(OutObject *)apiVersion;

- (EpassThruResult)PassThruGetLastError:(NSString *)errorDesc;

- (EpassThruResult)PassThruIoctl:(int)channelId :(EIoctlId)ioctlId :(id)inputConfig :(id)outoutCongig;

- (EpassThruResult)computeSA:(long)vendorCode :(short)alg :(NSMutableData *)seeds :(OutObject *)outKeys;




- (int)getFirmwareUpdateProgress;

- (int)restoreFirmware;

- (void)initDevice;

- (Device *)getDevice;

@end





























