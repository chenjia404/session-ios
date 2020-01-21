//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "ContactsManagerProtocol.h"
#import "TSYapDatabaseObject.h"
#import "TSAccountManager.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GroupType) {
    SIGNAL = 0,
    PUBLIC_CHAT = 1,
    RSS_FEED = 2
};

extern const int32_t kGroupIdLength;

@interface TSGroupModel : TSYapDatabaseObject

@property (nonatomic) NSArray<NSString *> *groupMemberIds;
@property (nonatomic) NSArray<NSString *> *groupAdminIds;
@property (nullable, readonly, nonatomic) NSString *groupName;
@property (readonly, nonatomic) NSData *groupId;
@property (nonatomic) GroupType groupType;
@property (nonatomic) NSMutableSet<NSString *> *removedMembers;

#if TARGET_OS_IOS
@property (nullable, nonatomic, strong) UIImage *groupImage;

- (instancetype)initWithTitle:(nullable NSString *)title
                    memberIds:(NSArray<NSString *> *)memberIds
                        image:(nullable UIImage *)image
                      groupId:(NSData *)groupId
                    groupType:(GroupType)groupType;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToGroupModel:(TSGroupModel *)model;
- (NSString *)getInfoStringAboutUpdateTo:(TSGroupModel *)model contactsManager:(id<ContactsManagerProtocol>)contactsManager;
- (void)updateGroupId: (NSData *)newGroupId;
#endif

@end

NS_ASSUME_NONNULL_END
