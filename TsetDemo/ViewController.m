//
//  ViewController.m
//  TsetDemo
//
//  Created by chenkai on 16/8/24.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ViewController.h"
#import "J2534.h"
#import "PassThruMsg.h"
#import "PassThruConfig.h"
#import "BytesConverter.h"
#import "OutObject.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *writeMsg;
@property (weak, nonatomic) IBOutlet UILabel *readMsg;

@property (nonatomic,strong)J2534 *j2;

@property (nonatomic,strong)OutObject *deviceId;

@property (nonatomic,strong)OutObject *perioId;

@property (nonatomic,strong)OutObject *channelId;

@property (nonatomic,strong)OutObject *filterId;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _writeMsg.text = @"000007101001";
}

- (J2534 *)j2{
    if (_j2 == nil) {
        _j2 = [[J2534 alloc] init];
    }
    return _j2;
}

- (IBAction)close:(id)sender {
    
    EpassThruResult ret = [self.j2 PassThruClose:[_deviceId.obj intValue]];
    if (ret == STATUS_NOERROR) {
        NSLog(@"关闭成功");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"关闭成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"关闭失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}
- (IBAction)open:(id)sender {
    
    
    OutObject *outDeviceid = [[OutObject alloc] init];
    EpassThruResult ret = [self.j2 PassThruOpen:@"vendid" :outDeviceid];
    NSLog(@"%@",outDeviceid.obj);
    if (ret == STATUS_NOERROR) {
        _deviceId = outDeviceid;
    }
    
//    ret = [self.j2 PassThruOpen:@"vendid" :[NSNumber numberWithInt:4]];
    NSLog(@"%ld",(long)ret);
    if (ret == STATUS_NOERROR) {
        
        NSLog(@"打开成功");
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"打开失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    };
}

- (IBAction)connect:(id)sender {
    OutObject *outChannelId = [[OutObject alloc] init];
    
    EpassThruResult ret = [self.j2 PassThruConnect:[_deviceId.obj intValue] :ISO15765 :0 :500000 :outChannelId];
    if (ret == STATUS_NOERROR) {
       _channelId = outChannelId;
    }

    
    
    if (ret == STATUS_NOERROR) {
        NSLog(@"连接成功");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"连接成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"连接失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    };

}
- (IBAction)write:(id)sender {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    PassThruMsg *pm = [[PassThruMsg alloc]init];
    pm.ProtocolId = ISO15765;
   
    
    
    BytesConverter *bc = [[BytesConverter alloc] init];
    
    [pm.Data appendData:[bc hexStrToBytes:_writeMsg.text]];
     pm.DataSize = (int)pm.Data.length;
    [arr addObject:pm];
    NSLog(@"%@",pm.Data);
    
    OutObject *outNum = [[OutObject alloc] init];
    
    EpassThruResult ret = [self.j2 PassThruWriteMsgs:[_channelId.obj intValue] :arr :outNum :-1];
    NSLog(@"%ld",(long)ret);
}




- (IBAction)startFilter:(id)sender {
    PassThruMsg *makMessage = [[PassThruMsg alloc] init];
    makMessage.ProtocolId = ISO15765;
    makMessage.DataSize = 4;
    BytesConverter *bc = [[BytesConverter alloc] init];
    makMessage.Data = (NSMutableData *)[bc hexStrToBytes:@"FFFFFFFF"];
    makMessage.TxFlags = 1;
    
    PassThruMsg *patternMsg = [[PassThruMsg alloc] init];
    patternMsg.ProtocolId = ISO15765;
    patternMsg.DataSize = 4;
    patternMsg.Data = (NSMutableData *)[bc hexStrToBytes:@"00000718"];
    patternMsg.TxFlags = 1;
    
    
    PassThruMsg *flowControlMsg = [[PassThruMsg alloc] init];
    flowControlMsg.ProtocolId = ISO15765;
    flowControlMsg.DataSize = 4;
    flowControlMsg.Data = (NSMutableData *)[bc hexStrToBytes:@"00000710"];
    flowControlMsg.TxFlags = 1;
    OutObject *outFilterId = [[OutObject alloc] init];
    EpassThruResult ret = [self.j2 PassThruStartMsgFilter:[_channelId.obj intValue] :FlowControl :makMessage :patternMsg :flowControlMsg :outFilterId];
    _filterId = outFilterId;
    NSLog(@"%ld--------------------------%d",(long)ret, [_filterId.obj intValue]);
    
}

- (IBAction)disconnect:(id)sender {
    
    EpassThruResult ret = [self.j2 PassThruDisconnect:[_channelId.obj intValue]];
    NSLog(@"%ld",(long)ret);
}

- (IBAction)stopFilter:(id)sender {
    
    EpassThruResult ret = [self.j2 PassThruStopMsgFilter:[_channelId.obj intValue] :[_filterId.obj intValue]];
    NSLog(@"%ld",(long)ret);
}

- (IBAction)read:(id)sender {
    OutObject *ob = [[OutObject alloc] init];
    ob.obj = [[NSMutableArray alloc] init];
    OutObject *outnum = [[OutObject alloc] init];
    outnum.obj = [[NSNumber alloc] initWithInt:1];
    
    EpassThruResult ret = [self.j2 PassThruReadMsgs:[_channelId.obj intValue] :ob :outnum :-1];
    if (ret == STATUS_NOERROR) {
        PassThruMsg *msg = ob.obj[0];
        
        NSString *str = [[[BytesConverter alloc] init] bytesToHexStr:msg.Data];
        _readMsg.text = str;
    }
    NSLog(@"%ld %@",(long)ret,ob.obj);
}


- (IBAction)startPeriod:(id)sender {
    
    PassThruMsg *pmsg = [[PassThruMsg alloc] init];
    pmsg.ProtocolId = ISO15765;
    pmsg.Data = (NSMutableData *)[[[BytesConverter alloc] init] hexStrToBytes:@"00000710021001"];
    pmsg.DataSize = (int)pmsg.Data.length;
    OutObject *outPeriodId = [[OutObject alloc] init];
    EpassThruResult ret = [self.j2 PassThruStartPeriodicMsg:[_channelId.obj intValue] :pmsg :outPeriodId :10];
    _perioId = outPeriodId;
    NSLog(@"PeriodResult-------------------------%ld",(long)ret);
}


- (IBAction)stopPeriod:(id)sender {
    EpassThruResult ret =  [self.j2 PassThruStopPeriodicMsg:[_channelId.obj intValue] :[_perioId.obj intValue]];
    NSLog(@"stopPeriodRet-----------------------%ld",(long)ret);
    
    
}

- (IBAction)icor:(id)sender {
    PassThruConfig *cfg = [[PassThruConfig alloc] init];
    [cfg add:LOOPBACK :1L];
    [cfg add:J1962_PINS :1550];
    [cfg.configMap setObject:[NSNumber numberWithInt:1550] forKey:@""];
    OutObject *obj = [[OutObject alloc] init];
    EpassThruResult ret =  [self.j2 PassThruIoctl:[_channelId.obj intValue] :SET_CONFIG :cfg :obj];
    NSLog(@"Ioctl--------------------------------------%ld",(long)ret);
}

- (IBAction)readVersion:(id)sender {
    OutObject *obj1 = [[OutObject alloc] init];
    OutObject *obj2 = [[OutObject alloc] init];
    OutObject *obj3 = [[OutObject alloc] init];
    EpassThruResult ret = [self.j2 PassThruReadVersion:[_deviceId.obj intValue] :obj1 :obj2 :obj3];
    NSLog(@"versionResult-------------------------------------------%ld",(long)ret);
    if (ret == 0) {
        NSLog(@"--------------------%@    %@     %@",obj1.obj,obj2.obj,obj3.obj);
    }
    
    
}

- (IBAction)compareSA:(id)sender {
    
    OutObject *obj = [[OutObject alloc] init];
    long a = 0x2ECDB585;
    NSMutableData *data = (NSMutableData *)[[[BytesConverter alloc] init] hexStrToBytes:@"02030405"];
    EpassThruResult ret = [self.j2 computeSA:a :10 :data :obj];
    NSLog(@"compute--------------------------------%ld", (long)ret);
    
    
}




@end


























