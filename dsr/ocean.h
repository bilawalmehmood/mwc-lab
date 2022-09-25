/*
 * This file functions as an ini or config
 * file would. Here we can change any parameter
 * used by any component of ocean, and also
 * turn debugging on/off for various components.
 *
 */

/* *** BEGIN MONITOR SECTION *** */

// comment this out if we do not wish monitor debug printing
#define MONITOR_DEBUG
// comment this out if we do not wish nodes to output their 
// status, eg, selfish or malicious or faulty
#define NODE_STATUS_DEBUG
// time in seconds until packets in cache timeout. 1ms (0.001sec)
// is the default time used in the OCEAN paper and functions well.
#define PACKET_TIMEOUT 0.5
// whether we are using a optimistic or pessimistic scheme,
// optimistic: we increment chip count after we send a packet
// to a node, regardless of whether that node forwards the packet.
// pessimistic: we only increment after we hear them forward.
// OPTIMISTIC_SCHEME 1 :: use optimistic scheme
// OPTIMISTIC_SCHEME 0 :: use pessimistic scheme
#define OPTIMISTIC_SCHEME 0

/* *** END MONITOR SECTION *** */

/* *** BEGIN BANK SECTION *** */

// comment this out if we do not wish bank debug printing
#define BANK_DEBUG
// # chips that nodes initially assign to their neighbours
#define INITIAL_CHIPCOUNT 200
// max # chips a node will allow its neighbour to attain
#define MAX_CHIPCOUNT 1000
// min # chips a node will allow its neighbour to attain
#define MIN_CHIPCOUNT 0
// # chips to increment account by when forwarding occurs
#define INCREMENT_AMOUNT 1
// # chips to decrement account by when requesting forwarding
#define DECREMENT_AMOUNT 1

/* *** END BANK SECTION *** */

/* *** BEGIN BANK TIMER SECTION *** */
// note: the frequency and amount should be proportionate to what
// is used in the simulation. If traffic is sent very often, then
// the frequency and/or amount should be increased as well. 

// comment this out if we do not wish bank timer debug printing
#define BANK_TIMER_DEBUG
// increment a neighbouring node's bank balance every X seconds
#define BANK_TIMER_FREQUENCY 4
// amount to increment every time
#define BANK_TIMER_AMOUNT 1

/* *** END BANK TIMER SECTION *** */

/* *** BEGIN REPUTATION SYSTEM SECTION *** */

// initial behaviour rating that nodes give other nodes when they first
// encounter them.
#define INITIAL_RATING 0
// amount to increase each time when registering positive event
#define INCREASE_RATING_AMOUNT 1
// amount to decrease each time when registering negative event
#define DECREASE_RATING_AMOUNT 2
// the faulty threshold, a node with rating below this is considered
// faulty and put on the list of faulty nodes
#define FAULTY_RATING_THRESHOLD -40
// the maximum positive rating a node can have
#define GOOD_RATING_THRESHOLD 40

/* *** END REPUTATION SYSTEM SECTION ***/

/* *** BEGIN ROUTE RANKER SECTION *** */

// comment this out if we do not wish route ranker debug printing
#define ROUTE_RANKER_DEBUG

/* *** END ROUTE RANKER SECTION *** */

/* *** BEGIN MALICIOUS TRAFFIC REJECTION SECTION *** */

// comment this out if we do not wish malicious traffic rejection debugging
#define MALICIOUS_TRAFFIC_REJECTION_DEBUG

/* *** END MALICIOUS TRAFFIC REJECTION SECTION *** */

/* *** BEGIN SECOND CHANCE MECHANISM SECTION *** */
// comment this out if we do not wish second chance mechanism debugging
#define SECOND_CHANCE_MECHANISM_DEBUG
// time in seconds before a node is taken off of the faulty list
#define SEC_CHANCE_TIMEOUT_PERIOD 30
// new rating a node receives when it is taken off the faulty list
#define SEC_CHANCE_NEW_RATING -30
/* *** END SECOND CHANCE MECHANISM SECTION *** */
