
#import "AnylineMRZScanViewController.h"
#import <Anyline/Anyline.h>

@interface AnylineMRZScanViewController ()<AnylineMRZModuleDelegate>

@end

@implementation AnylineMRZScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        AnylineMRZModuleView *mrzModuleView = [[AnylineMRZModuleView alloc] initWithFrame:self.view.bounds];
        mrzModuleView.currentConfiguration = self.conf;
        
        NSError *error = nil;
        [mrzModuleView setupWithLicenseKey:self.key delegate:self error:&error];
//        if(!success) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setup failed:" message:error.debugDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//        }
        
        self.moduleView = mrzModuleView;
        
        [self.view addSubview:self.moduleView];
        
        [self.view sendSubviewToBack:self.moduleView];
    });
}

#pragma mark - AnylineMRZModuleDelegate method


-(void)anylineMRZModuleView:(AnylineMRZModuleView *)anylineMRZModuleView didFindResult:(ALMRZResult *)scanResult {
    
    
    NSMutableDictionary *scanResultDict = [[scanResult.result dictionaryWithValuesForKeys:@[@"documentType",
                                                                                     @"nationalityCountryCode",
                                                                                     @"issuingCountryCode",
                                                                                     @"surNames",
                                                                                     @"givenNames",
                                                                                     @"documentNumber",
                                                                                     @"checkdigitNumber",
                                                                                     @"dayOfBirth",
                                                                                     @"checkdigitDayOfBirth",
                                                                                     @"sex",
                                                                                     @"expirationDate",
                                                                                     @"checkdigitExpirationDate",
                                                                                     @"personalNumber",
                                                                                     @"checkDigitPersonalNumber",
                                                                                     @"checkdigitFinal"]] mutableCopy];
    self.scannedLabel.text = scanResultDict.description;
    
    NSString *imagePath = [self saveImageToFileSystem:scanResult.image];
    
    [scanResultDict setValue:imagePath forKey:@"imagePath"];
    [scanResultDict setValue:@(scanResult.allCheckDigitsValid) forKey:@"allCheckDigitsValid"];
    
    [scanResultDict setValue:@(scanResult.confidence) forKey:@"confidence"];
    [scanResultDict setValue:[self stringForOutline:scanResult.outline] forKey:@"outline"];
    

    
    [self.delegate anylineBaseScanViewController:self didScan:scanResultDict continueScanning:!self.moduleView.cancelOnResult];
    
    if (self.moduleView.cancelOnResult) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
