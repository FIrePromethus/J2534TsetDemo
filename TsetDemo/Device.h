//
//  Device.h
//  J2534
//
//  Created by chenkai on 16/8/11.
//  Copyright © 2016年 陈凯. All rights reserved.
//




#import <Foundation/Foundation.h>
#import "IDataPipe.h"
#import "SystemError.h"
#import "J2534.h"
@class TxMwssage,PhysicalChannel,CANLogalChannel,ISO14230Channel,ISO15765Channel,BOSCH5_3LogicalChannel,LogcalChanenel,DataHub,FirwareProgram,NetworkFrame,DataLinker,HandlerChain;
typedef NS_ENUM(NSInteger,ElinkResult){
    NoError = 0,
    SocketNotConnected,
    SocketSendFailed,
    NullParameter,
    Failed,
    Timeout,
    ChannelInUse,
    ChannelNotOpen,
    NotSupport
};

@protocol Linker <NSObject>

- (ElinkResult)sendTxMwssage:(TxMwssage *)data;

- (ElinkResult)sendDataList:(NSArray<TxMwssage *> *)dataColl;

- (ElinkResult)connet;

- (ElinkResult)disconnect;

- (BOOL)isConnected;

- (ElinkResult)readSN:(NSString *)outSn;

- (ElinkResult)readFirmwareVersion:(OutObject *)outVersion;

- (ElinkResult)openCANChannel:(NSMutableArray<NSData *> *)chOptionList;

- (ElinkResult)closeCANChannel:(NSData *)options;

- (ElinkResult)readVoltage:(NSNumber *)outVol ;

- (void)setVendorId:(long)vendorId;

- (ElinkResult)computeSA:(long)vendorCode :(short)alg :(NSMutableData *)seeds :(OutObject *)outKeys;

- (ElinkResult)openKChennel:(int)baud;

- (ElinkResult)closeKChannel;

- (ElinkResult)openBOSCH5_3Channel:(Byte)target;

- (ElinkResult)closeBOSCH5_3Channel;

- (HandlerChain *)getChain;

- (ElinkResult)restoreFirmware;


- (ElinkResult)changeMode:(int)mode;

@end



@interface Device : NSObject<IDataPipe>
@property(nonatomic,strong) id<Linker>delege;
@property(nonatomic,strong) NSMutableArray<PhysicalChannel *> *phyChannelList;

@property(nonatomic,assign) int Id;
@property(nonatomic,strong) CANLogalChannel *ISOCANChannel;
@property(nonatomic,strong) ISO15765Channel *ISO15765Channel;
@property(nonatomic,strong) ISO14230Channel *ISO14230Channel;
@property(nonatomic,strong) BOSCH5_3LogicalChannel *BOSCH5_3LogicalChannel;
@property(nonatomic,strong) NSMutableArray<LogcalChanenel *> *logicChannelColl;
@property(nonatomic,strong) NSMutableArray<NSNumber *> *validJ1962Pins;
@property(nonatomic,strong) DataHub *dataHub;
@property(nonatomic,strong) FirwareProgram *program;

- (EpassThruResult)open;

- (EpassThruResult)close;

- (EpassThruResult)openChannel:(EProtocolId)protocolId :(long)baudrate :(long)flags :(OutObject *)outChannel;

- (EpassThruResult)openChannelInternal:(LogcalChanenel *)logicChannel :(long)baudrate;

- (EpassThruResult)checkCANChannelIsValid:(EProtocolId)protocolId :(EProtocolId)protocolId_PS;

- (LogcalChanenel *)findChannel:(int)Id;

- (EpassThruResult)closeChannel:(int)channelId;

- (PhysicalChannel *)getPhysicalChannel:(LogcalChanenel *)logicChannel;

- (EpassThruResult)readMsgs:(int)channelId :(OutObject *)outMsgList :(OutObject *)inOutNum :(int)timeout;

- (EpassThruResult)writeMsgs:(int)channelId :(NSMutableArray<PassThruMsg *> *)inMsgList :(OutObject *)outNum :(int)timeout;

- (EpassThruResult)switchPin:(LogcalChanenel *)ch :(NSNumber *)j1962Pins;

- (EpassThruResult)getSN:(NSString *)outSn;

- (EpassThruResult)getFirmwareVersion:(OutObject *)outVersion;

- (double)readVoltage;


- (void)setVendorId:(long)vensorId;

- (EpassThruResult)computeSA:(long)vendorCode :(short)alg :(NSData *)seeds :(OutObject *)outKeys;

- (void)setTaansmitOnly:(BOOL)isTransmitOnly;

- (int)restoreFirmware;

- (BOOL)changeMode:(int)mode;

@end

































