//
//  ValidateInputForm.m
//  Grid
//
//  Created by nmi on 2017/6/7.
//  Copyright © 2017年 ChunTa Chen. All rights reserved.
//

#import "ValidateInputForm.h"
#import "DJProgressHUD.h"
#import "DJProgressIndicator.h"
#import "DJActivityIndicator.h"
#import "AFHTTPSessionManager.h"
#import "ValidationHelper.h"
#import "NSAttributedString+HyperLink.h"

#define EXP_ORG 225
#define EXP_LINES 300
#define REGI_URL @"http://localhost:3000/product/validate"
#define PINVERIFY_URL @"http://localhost:3000/product/pin_verify"
#define MAX_PINCODE_NPUT 4
#define DELAY_FOR_OK 2
@interface ValidateInputForm()<NSTextFieldDelegate>
@property(nonatomic, strong)IBOutlet NSView *emailBgView;
@property(nonatomic, strong)IBOutlet NSView *lckeyBgView;
@property(nonatomic, strong)IBOutlet NSTextField *titleTxt;
@property(nonatomic, strong)IBOutlet NSTextField *emailTxt;
@property(nonatomic, strong)IBOutlet NSTextField *lckeyTxt;
@property(nonatomic, strong)IBOutlet NSTextField *hintTxt;
@property(nonatomic, strong)IBOutlet NSButton *regiBtn;
@property(nonatomic, strong)IBOutlet NSButton *closeBtn;
@property(nonatomic, strong)IBOutlet NSBox *botleftLine;
@property(nonatomic, strong)IBOutlet NSBox *botrightLine;
@property(nonatomic, strong)IBOutlet NSImageView* okerrorIcon;
@property(nonatomic, strong)DJProgressIndicator* progress;
@property(nonatomic, strong)DJActivityIndicator* actindicator;

//digi input
@property(nonatomic, strong)IBOutlet NSView *pincodeView;
@property(nonatomic, strong)IBOutlet NSTextField *pincodeInput;
@property(nonatomic, strong)IBOutlet NSButton *confirmPincodeBtn;
@property(nonatomic, strong)IBOutlet NSButton *closePincodeBtn;
@end

@implementation ValidateInputForm
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.emailBgView.wantsLayer = YES;
    self.emailBgView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.lckeyBgView.wantsLayer = YES;
    self.lckeyBgView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [self hidePincode];
}

- (void)enableUIControl:(BOOL)enabled
{
    self.emailTxt.enabled = enabled;
    self.lckeyTxt.enabled = enabled;
    self.regiBtn.enabled = enabled;
    self.closeBtn.enabled = enabled;
    self.titleTxt.textColor = (enabled)?[NSColor blackColor]:[NSColor lightGrayColor];
    
    //pincode
    self.pincodeInput.enabled = enabled;
    self.confirmPincodeBtn.enabled = enabled;
    self.closePincodeBtn.enabled = enabled;
}

- (void)localSaveEmailAndLcnkey
{
    NSAssert(self.emailTxt.stringValue.length, @"Email should not be empty");
    NSAssert(self.lckeyTxt.stringValue.length, @"Licensekey should not be empty");
    [[NSUserDefaults standardUserDefaults] setObject:self.emailTxt.stringValue forKey:kRegistrationMail];
    [[NSUserDefaults standardUserDefaults] setObject:self.lckeyTxt.stringValue forKey:kRegistrationKey];
}

-(NSMutableAttributedString *)stringFromHTML:(NSString *)html withFont:(NSFont *)font
{
    if (!font) font = [NSFont systemFontOfSize:0.0];  // Default font
    html = [NSString stringWithFormat:@"<span style=\"font-family:'%@'; font-size:%dpx;\">%@</span>", [font fontName], (int)[font pointSize], html];
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithHTML:data documentAttributes:nil];
    return string;
}

- (void)handleErrorCode:(NSString*)scode TransferHW:(BOOL)transfer
{
    [self enableUIControl:YES];
    if ([scode isEqualToString:CODE_OK])
    {
        [self enableUIControl:NO];
        [self localSaveEmailAndLcnkey];
        NSString *str = (transfer==NO)?@"Registration OK.":@"Verifying owner done";
        [self showStatus:str Show:YES IsError:NO Alignment:NSTextAlignmentCenter Font:[NSFont systemFontOfSize:12] SupportURL:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_FOR_OK * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate onValidateFormRegisterOK];
        });
    }
    else if ([scode isEqualToString:CODE_LICENSEKEY_INCORRECT])
    {
        [self showStatus:@"Licensekey or mail is incorrect." Show:YES IsError:YES Alignment:NSTextAlignmentCenter Font:[NSFont systemFontOfSize:12] SupportURL:NO];
    }
    else if ([scode isEqualToString:CODE_EMAIL_INCORRECT])
    {
        [self showStatus:@"Licensekey or mail is incorrect." Show:YES IsError:YES Alignment:NSTextAlignmentCenter Font:[NSFont systemFontOfSize:12] SupportURL:NO];
    }
    else if ([scode isEqualToString:CODE_SNO_MISMATCH])
    {
        [self showPincode];
        [self showStatus:nil Show:NO IsError:NO Alignment:NSTextAlignmentCenter Font:[NSFont systemFontOfSize:12] SupportURL:NO];
    }
    else if ([scode isEqualToString:CODE_ORDER_ERROR])
    {
        [self showStatus:@"Code(4) Please contact: " Show:YES IsError:YES Alignment:NSTextAlignmentLeft Font:[NSFont systemFontOfSize:12] SupportURL:YES];
    }
    else if ([scode isEqualToString:CODE_UNKNOWN_ERROR])
    {
        [self showStatus:@"Code(5) Please check your internet service or contact: " Show:YES IsError:YES Alignment:NSTextAlignmentLeft Font:[NSFont systemFontOfSize:12] SupportURL:YES];
    }
    else if ([scode isEqualToString:CODE_PINCODE_INCORRECT])
    {
        [self showStatus:@"Pincode is incorrect." Show:YES IsError:YES Alignment:NSTextAlignmentCenter Font:[NSFont systemFontOfSize:12] SupportURL:NO];
    }
}

- (void)showStatus:(NSString*)str Show:(BOOL)show IsError:(BOOL)error Alignment:(NSTextAlignment)align Font:(NSFont*)font SupportURL:(BOOL)support
{
    self.okerrorIcon.hidden = !show;
    self.hintTxt.hidden = !show;
    if (show)
    {
        NSMutableAttributedString *attstr = [self stringFromHTML:str withFont:font];
        if (support)
        {
            NSURL* url = [NSURL URLWithString:@"http://mildgrind.com"];
            [attstr appendAttributedString:[NSAttributedString hyperlinkFromString:@"MildGrind" withURL:url]];
        }
        NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
        [mutParaStyle setAlignment:align];
        [attstr addAttributes:[NSDictionary dictionaryWithObject:mutParaStyle forKey:NSParagraphStyleAttributeName] range:NSMakeRange(0,[attstr length])];
        
        [self.hintTxt setAllowsEditingTextAttributes: YES];
        [self.hintTxt setSelectable:YES];
        [self.hintTxt setAttributedStringValue:attstr];
        [self.delegate onValidateFormExpand:EXP_LINES];
        [self.okerrorIcon setImage:(error)?[NSImage imageNamed:@"error_icon.png"]:[NSImage imageNamed:@"check_icon.png"]];
        self.botleftLine.hidden = NO;
        self.botrightLine.hidden = NO;
    }
    else
    {
        [self.delegate onValidateFormExpand:EXP_ORG];
        self.botleftLine.hidden = YES;
        self.botrightLine.hidden = YES;
    }
}

#pragma mark - ActivityView
- (void)createActivityView:(NSView*)parent
{
    [self destroyActivityView];
    [self enableUIControl:NO];
    
    NSSize size = NSMakeSize(30, 30);
    NSPoint center = NSMakePoint(parent.frame.size.width/2, parent.frame.size.height/2);
    self.actindicator = [[DJActivityIndicator alloc] initWithFrame:NSMakeRect(center.x-size.width/2, center.y-size.height/2, size.width, size.height)];
    [self.actindicator setBackgroundColor:[NSColor clearColor]];
    [self.actindicator startAnimation:nil];
    [parent addSubview:self.actindicator];
}

- (void)destroyActivityView
{
    if (self.actindicator)
    {
        [self.actindicator removeFromSuperview];
        self.actindicator = nil;
    }
}

- (IBAction)onRegister:(id)sender
{
    if (self.emailTxt.stringValue.length && self.lckeyTxt.stringValue.length)
    {
        [self createActivityView:self.view];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:REGI_URL]];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"email=%@&licensekey=%@&sno=%@", self.emailTxt.stringValue, self.lckeyTxt.stringValue, getPlatformSerialNumber()];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       
                                                       //Remove indicator
                                                       [self destroyActivityView];
                                                       
                                                       //Error or state handling
                                                       if (!connectionError)
                                                       {
                                                           NSError* error;
                                                           NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                           NSString *scode = [NSString stringWithFormat:@"%d", [[json objectForKey:@"code"] intValue]];
                                                           [self handleErrorCode:scode TransferHW:NO];
                                                       }
                                                       else
                                                       {
                                                           [self handleErrorCode:CODE_UNKNOWN_ERROR TransferHW:NO];
                                                       }
                                                       //-------
                                                   });
                                   
        }];        
    }
}

- (IBAction)onClose:(id)sender
{
    [self.delegate onValidateFormClose];
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    if (control==self.pincodeInput)
    {
        if (self.pincodeInput.stringValue.length >= MAX_PINCODE_NPUT)
        {
            NSString *forinput = [self.pincodeInput.stringValue substringWithRange:NSMakeRange(0, MAX_PINCODE_NPUT)];
            [self.pincodeInput setStringValue:forinput];
        }
    }
    else
    {
        [self showStatus:@"" Show:NO IsError:NO Alignment:NSTextAlignmentCenter Font:nil SupportURL:NO];
    }
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    if (self.pincodeInput.stringValue.length > MAX_PINCODE_NPUT)
    {
        NSString *forinput = [self.pincodeInput.stringValue substringWithRange:NSMakeRange(0, MAX_PINCODE_NPUT)];
        [self.pincodeInput setStringValue:forinput];
    }
}

//Pincode Input
- (void)showPincode
{
    self.pincodeView.hidden = NO;
    
    self.emailBgView.hidden = YES;
    self.lckeyBgView.hidden = YES;
    self.emailTxt.hidden = YES;
    self.lckeyTxt.hidden = YES;
    self.hintTxt.hidden = YES;
    self.regiBtn.hidden = YES;
    self.closeBtn.hidden = YES;
    self.botleftLine.hidden = YES;
    self.botrightLine.hidden = YES;
}

- (void)hidePincode
{
    self.pincodeView.hidden = YES;
}

- (IBAction)onPincodeConfirm:(id)sender
{
    if (self.pincodeInput.stringValue.length == MAX_PINCODE_NPUT)
    {
        [self createActivityView:self.pincodeView];
        
        //pin_verify
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:PINVERIFY_URL]];
        [request setHTTPMethod:@"POST"];
        NSString *postString = [NSString stringWithFormat:@"email=%@&licensekey=%@&sno=%@&pincode=%@", self.emailTxt.stringValue,
                                self.lckeyTxt.stringValue, getPlatformSerialNumber(), self.pincodeInput.stringValue];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       //Remove indicator
                                       [self destroyActivityView];
                                       
                                       //Error or state handling
                                       if (!connectionError)
                                       {
                                           NSError* error;
                                           NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           NSString *scode = [NSString stringWithFormat:@"%d", [[json objectForKey:@"code"] intValue]];
                                           [self handleErrorCode:scode TransferHW:YES];
                                       }
                                       else
                                       {
                                           [self handleErrorCode:CODE_UNKNOWN_ERROR  TransferHW:NO];
                                       }
                                       //-------
                                   });
                                   
                               }];
    }
}

- (IBAction)onPincodeClose:(id)sender
{
    [self.delegate onValidateFormClose];
}
@end
