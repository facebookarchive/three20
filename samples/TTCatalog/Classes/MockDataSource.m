
#import "MockDataSource.h"

@interface MockAddressBook ()
- (void) loadNames;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MockAddressBook

@synthesize names = _names, fakeSearchDuration = _fakeSearchDuration, fakeLoadingDuration = _fakeLoadingDuration;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (NSMutableArray*)fakeNames {
  return [NSMutableArray arrayWithObjects:
  @"Hector Lewis",
  @"Juanita Fredrick",
  @"Richard Raymond",
  @"Marcia Myer",
  @"Shannon Mahoney",
  @"James Steiner",
  @"Daniel Lloyd",
  @"Fredrick Hutchins",
  @"Tracey Smith",
  @"Brandon Rutherford",
  @"Megan Lopez",
  @"Jean Trujillo",
  @"Franklin Diamond",
  @"Mildred Jacobsen",
  @"Sandra Adams",
  @"Debra Pugliese",
  @"Cynthia Hall",
  @"Joshua Hicks",
  @"Lorenzo Evatt",
  @"Erica Dozier",
  @"Barbara Lazarus",
  @"Joye Hocker",
  @"Henry Arana",
  @"Glen Cabrales",
  @"Mai Valdez",
  @"Travis Book",
  @"John Ibanez",
  @"Barbara White",
  @"Cassandra Smith",
  @"Virginia Costilla",
  @"Rachel Baker",
  @"Mildred Foley",
  @"Todd Nevels",
  @"William Boes",
  @"Claire Harrell",
  @"Charlotte Espinoza",
  @"Gerald Miller",
  @"Lucille Lankford",
  @"Lloyd Fritz",
  @"Charlie Cabrera",
  @"Shane Vogt",
  @"Cynthia Simon",
  @"Clayton Land",
  @"Roy Stahl",
  @"Helen Peralta",
  @"Reinaldo Self",
  @"Thomas Carter",
  @"Anthony Hebert",
  @"Timothy Abernathy",
  @"Rob Magruder",
  @"Ira Kaplan",
  @"Dixie Gurney",
  @"Darrin Pritchard",
  @"Patrick Brooks",
  @"Norman Sanchez",
  @"Vickie Robbins",
  @"Santiago Chiles",
  @"Douglas Bearden",
  @"Cora Jones",
  @"Donald Kennedy",
  @"Henry Nelson",
  @"Rosa Judge",
  @"Andrew Khan",
  @"Lauretta Rose",
  @"Mildred Nance",
  @"Antoinette Delarosa",
  @"Stephanie Johnson",
  @"Geoffrey Perry",
  @"Sally Houston",
  @"Pamela Pellegrin",
  @"Nereida Faul",
  @"Nichole Moore",
  @"David Thompson",
  @"Rob Burt",
  @"Mary Gelb",
  @"Glenda Stgeorge",
  @"Lydia Freeman",
  @"Otto Brown",
  @"Erica Cooke",
  @"Evelyn Stephens",
  @"Vanessa Ayers",
  @"Jeffrey Kirk",
  @"Christine Stradford",
  @"John Murphy",
  @"Paul Pederson",
  @"Genevieve Barrett",
  @"Stanley Kelly",
  @"Marie Noel",
  @"Mike Mathis",
  @"Albert Gary",
  @"Alice Thomas",
  @"Anna Bond",
  @"Bobby Gaines",
  @"Helen Ellis",
  @"Bobbie Thayer",
  @"Dorothy Totten",
  @"Laura Wegener",
  @"Pam Hackett",
  @"Arlene Blount",
  @"James Clark",
  @"Richard Harris",
  @"Joseph Cain",
  @"Stacy Jones",
  @"Bonnie Gonzalez",
  @"Maria Bailey",
  @"Francis Caldwell",
  @"Anthony Gale",
  @"John Zackery",
  @"Patricia Taylor",
  @"Kimberly Jarrett",
  @"Carol Dennie",
  @"Betty Zager",
  @"Ellen Godines",
  @"Edward Adams",
  @"Ricky Salamanca",
  @"Elizabeth Ruvalcaba",
  @"Veronica Esposito",
  @"Russel Owen",
  @"Harry Plascencia",
  @"Thomas Dewalt",
  @"Robert Eldred",
  @"Frank Buerger",
  @"Phillip James",
  @"James Beverly",
  @"Michael Mcallister",
  @"George Nichols",
  @"Richard Larson",
  @"Patricia Ramirez",
  @"Rob Govan",
  @"Charles Johnston",
  @"David Rogers",
  @"Homer Allen",
  @"Carolyn Green",
  @"Velma Beery",
  @"Ida Garcia",
  @"Jasmine Creighton",
  @"Ozie Templin",
  @"Julia Hudson",
  @"David Cortez",
  @"Tina Henderson",
  @"Janette Bray",
  @"Michael Hamilton",
  @"Andrew Bennett",
  @"Margarita Lehmann",
  @"Stephanie Whitehead",
  @"Mary Saladino",
  @"Nicholas Alaniz",
  @"John Escobedo",
  @"Macie Workman",
  @"Michelle Thomas",
  @"Robert Carvalho",
  @"Allen Johnson",
  @"Will Norris",
  @"Matthew Mabrey",
  @"Vicki Howard",
  @"Annie Campbell",
  @"Stephen Anderson",
  @"Leah Scott",
  @"Dominic Winters",
  @"Catherine Rondeau",
  @"Amanda Hall",
  @"Michael Hucks",
  @"Truman Vidal",
  @"Jennifer Worley",
  @"Jack Fiore",
  @"Douglas Irby",
  @"Ana Bonilla",
  @"Jacob Lankford",
  @"Robert Garcia",
  @"Helene Arispe",
  @"Ola Barnhill",
  @"Rosario Delaney",
  @"Robert Estes",
  @"Karen Carter",
  @"Hazel Thompson",
  @"Rebecca Mack",
  @"Lashawn Rice",
  @"Harry Davis",
  @"Matilda Woodbury",
  @"Celia Barnhart",
  @"Ava Murray",
  @"John Williams",
  @"Debbie Watts",
  @"Karen Borel",
  @"Neta Yingst",
  @"Roy Carter",
  @"Leon Roberts",
  @"Evette Jones",
  @"Dianna Adams",
  @"Brian Reed",
  @"Joyce Ritter",
  @"Stephen Diaz",
  @"Elizabeth Shealey",
  @"Barbara Hatch",
  @"Doug Harrison",
  @"Sharon Castro",
  @"Juan Frakes",
  @"Gary Berry",
  @"Helen Zamora",
  @"Sarah Woodard",
  @"Phillip Hebert",
  @"Weldon Goldsmith",
  @"Lisa Segura",
  @"Adrienne Pedroza",
  @"Alfred Ransom",
  @"Everett Rambo",
  @"John Phillips",
  @"Carol Mccabe",
  @"James Martinez",
  @"Trang Strickland",
  @"Linda Brown",
  @"Shayla Hodgson",
  @"Magdalena Moore",
  @"Gwendolyn Meyers",
  @"Stephen Williams",
  @"Pamela Radford",
  @"Jeffrey Hooker",
  @"David Catania",
  @"Marvin Miller",
  @"Laura Murray",
  @"Dorothy James",
  @"Susannah Gibson",
  @"Melissa Owens",
  @"Deborah Horrell",
  @"Franklin Williams",
  @"Scott Brown",
  @"Adam Gautreaux",
  @"Joseph Byers",
  @"Deborah Barker",
  @"Linda Virgin",
  @"Patricia Mitchell",
  @"John Donovan",
  @"Robert Hamill",
  @"Jamel Mcmillen",
  @"Patty Guzzi",
  @"Mildred Leon",
  @"Benjamin Mapes",
  @"Allen Cave",
  @"Patrick Sims",
  @"Patrick Mercado",
  @"Joyce Orozco",
  @"Gloria Bell",
  @"Gerard Kelley",
  @"Molly Grant",
  @"Patrick Perez",
  @"John Corey",
  @"Ryan Clemmer",
  @"James Davis",
  @"Kevin Scarborough",
  @"Frankie Montagna",
  @"Terry Joseph",
  @"Ira Boyle",
  @"Kathryn Hildebrandt",
  @"James Larson",
  @"Shelia Easter",
  @"Gabriel Dorsett",
  @"Irene Mcbroom",
  @"Robert Hardin",
  @"Sue Grossi",
  @"Rebecca Stock",
  @"Ruby Kiefer",
  @"John Sandoval",
  @"Peter King",
  @"Joseph Fleming",
  @"Joan Swenson",
  @"Conrad Savory",
  @"Grant Kowalewski",
  @"Shirley Garcia",
  @"Dorris West",
  @"Jane Tran",
  @"Meaghan Lam",
  @"Jorge White",
  @"Catherine Whittaker",
  @"Katherine Hope",
  @"Maria Underwood",
  @"Rose Ray",
  @"Samatha Sedlacek",
  @"Jerri Sampson",
  @"Loren Bourdeau",
  @"William Wilson",
  @"Stephen Canady",
  @"Elaine Ruth",
  @"Marcus Martin",
  @"Aileen Kemp",
  @"Kevin Maupin",
  @"Martha Vanwinkle",
  @"Kelly Munk",
  @"Lisa Rosato",
  @"Marcella Jett",
  @"Barbara Murphy",
  @"Edward Sherrod",
  @"Jane Cushing",
  @"Clara Sims",
  @"Velma Moreno",
  @"Eric Noguera",
  @"Shirley Williams",
  @"Gina Millard",
  @"Edward Deputy",
  @"Jennifer Myers",
  @"Mary Spurgeon",
  nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)fakeSearch:(NSString*)text {
  self.names = [NSMutableArray array];

  if (text.length) {
    text = [text lowercaseString];
    for (NSString* name in _allNames) {
      if ([[name lowercaseString] rangeOfString:text].location == 0) {
        [_names addObject:name];
      }
    }
  }

  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)fakeSearchReady:(NSTimer*)timer {
  _fakeSearchTimer = nil;

  NSString* text = timer.userInfo;
  [self fakeSearch:text];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNames:(NSArray*)names {
  if (self = [super init]) {
    _delegates = nil;
    _allNames = [names copy];
    _names = nil;
    _fakeSearchTimer = nil;
    _fakeSearchDuration = 0;
  }
  return self;
}

- (void)dealloc {
  TT_INVALIDATE_TIMER(_fakeSearchTimer);
  TT_INVALIDATE_TIMER(_fakeLoadingTimer)
  TT_RELEASE_SAFELY(_delegates);
  TT_RELEASE_SAFELY(_allNames);
  TT_RELEASE_SAFELY(_names);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = TTCreateNonRetainingArray();
  }
  return _delegates;
}

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isOutdated {
  return NO;
}

- (BOOL)isLoaded {
  return !!_names;
}

- (BOOL)isLoading {
  return !!_fakeSearchTimer || !!_fakeLoadingTimer;
}

- (BOOL)isEmpty {
  return !_names.count;
}

- (void) fakeLoadingReady {
  _fakeLoadingTimer = nil;
    
  [self loadNames];

  [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
  if (_fakeLoadingDuration) {
    TT_INVALIDATE_TIMER(_fakeLoadingTimer);
    _fakeLoadingTimer = [NSTimer scheduledTimerWithTimeInterval:_fakeLoadingDuration target:self
                                                       selector:@selector(fakeLoadingReady) userInfo:nil repeats:NO];
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
  } else {
    [self loadNames];
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
  }
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
  if (_fakeSearchTimer) {
    TT_INVALIDATE_TIMER(_fakeSearchTimer);
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
  } else if(_fakeLoadingTimer) {
    TT_INVALIDATE_TIMER(_fakeLoadingTimer);
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];    
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)loadNames {
  TT_RELEASE_SAFELY(_names);
  _names = [_allNames mutableCopy];
}

- (void)search:(NSString*)text {
  [self cancel];

  TT_RELEASE_SAFELY(_names);
  if (text.length) {
    if (_fakeSearchDuration) {
      TT_INVALIDATE_TIMER(_fakeSearchTimer);
      _fakeSearchTimer = [NSTimer scheduledTimerWithTimeInterval:_fakeSearchDuration target:self
                                selector:@selector(fakeSearchReady:) userInfo:text repeats:NO];
      [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
    } else {
      [self fakeSearch:text];
      [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
    }
  } else {
    [_delegates perform:@selector(modelDidChange:) withObject:self];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MockDataSource

@synthesize addressBook = _addressBook;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _addressBook = [[MockAddressBook alloc] initWithNames:[MockAddressBook fakeNames]];
    self.model = _addressBook;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_addressBook);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return [TTTableViewDataSource lettersForSectionsWithSearch:YES summary:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];
  self.sections = [NSMutableArray array];

  NSMutableDictionary* groups = [NSMutableDictionary dictionary];
  for (NSString* name in _addressBook.names) {
    NSString* letter = [NSString stringWithFormat:@"%C", [name characterAtIndex:0]];
    NSMutableArray* section = [groups objectForKey:letter];
    if (!section) {
      section = [NSMutableArray array];
      [groups setObject:section forKey:letter];
    }

    TTTableItem* item = [TTTableTextItem itemWithText:name URL:nil];
    [section addObject:item];
  }

  NSArray* letters = [groups.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (NSString* letter in letters) {
    NSArray* items = [groups objectForKey:letter];
    [_sections addObject:letter];
    [_items addObject:items];
  }
}

- (id<TTModel>)model {
  return _addressBook;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MockSearchDataSource

@synthesize addressBook = _addressBook;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithDuration:(NSTimeInterval)duration {
  if (self = [super init]) {
    _addressBook = [[MockAddressBook alloc] initWithNames:[MockAddressBook fakeNames]];
    _addressBook.fakeSearchDuration = duration;
    self.model = _addressBook;
  }
  return self;
}

- (id)init {
  return [self initWithDuration:0];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_addressBook);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (void)tableViewDidLoadModel:(UITableView*)tableView {
  self.items = [NSMutableArray array];

  for (NSString* name in _addressBook.names) {
    TTTableItem* item = [TTTableTextItem itemWithText:name URL:@"http://google.com"];
    [_items addObject:item];
  }
}

- (void)search:(NSString*)text {
  [_addressBook search:text];
}

- (NSString*)titleForLoading:(BOOL)reloading {
  return @"Searching...";
}

- (NSString*)titleForNoData {
  return @"No names found";
}

@end
