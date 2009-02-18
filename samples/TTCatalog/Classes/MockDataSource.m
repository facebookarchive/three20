
#import "MockDataSource.h"

@implementation MockDataSource

+ (MockDataSource*)mockDataSource:(BOOL)forSearch {
  MockDataSource* dataSource =  [[[MockDataSource alloc] initWithNames:
    [NSMutableArray arrayWithObjects:
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
    nil]] autorelease];

  if (!forSearch) {
    [dataSource rebuildItems];
  }

  return dataSource;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithNames:(NSArray*)names {
  if (self = [super init]) {
    _names = [names copy];
  }
  return self;
}

- (void)dealloc {
  [_names release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return self.lettersForSections;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object {
  TTTableField* field = object;
  return field.text;
}

- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell
        forRowAtIndexPath:(NSIndexPath*)indexPath {
  cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView*)tableView search:(NSString*)text {
  [_sections release];
  _sections = nil;
  [_items release];

//  _items = [[NSMutableArray alloc] initWithObjects:
//    [[[TTActivityTableField alloc] initWithText:@"Searching..."] autorelease],
//    nil];

  if (text.length) {
    _items = [[NSMutableArray alloc] init];
    
    text = [text lowercaseString];
    for (NSString* name in _names) {
      if ([[name lowercaseString] rangeOfString:text].location == 0) {
          TTTableField* field = [[[TTTableField alloc] initWithText:name href:TT_NULL_URL]
            autorelease];
          [_items addObject:field];
      }
    }    
  } else {
    _items = nil;
  }
  
  [self dataSourceLoaded];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)rebuildItems {
  NSMutableDictionary* map = [NSMutableDictionary dictionary];
  for (NSString* name in _names) {
    NSString* letter = [NSString stringWithFormat:@"%c", [name characterAtIndex:0]];
    NSMutableArray* section = [map objectForKey:letter];
    if (!section) {
      section = [NSMutableArray array];
      [map setObject:section forKey:letter];
    }
    
    TTTableField* field = [[[TTTableField alloc] initWithText:name href:TT_NULL_URL] autorelease];
    [section addObject:field];
  }
  
  [_items release];
  _items = [[NSMutableArray alloc] init];
  [_sections release];
  _sections = [[NSMutableArray alloc] init];

  NSArray* letters = [map.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  
  for (NSString* letter in letters) {
    NSArray* items = [map objectForKey:letter];
    [_sections addObject:letter];
    [_items addObject:items];
  }
}

@end
