//
//  MTPDFPage.h
//  FomalhautOSX
//
//  Created by User on 1/12/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "MTPage.h"
#import <Quartz/Quartz.h>

@interface MTPDFPage : MTPage

- (id)initWithPDFPage:(PDFPage *)pdfPage;

@end
