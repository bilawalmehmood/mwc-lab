#include "monitor.h"
#include <iostream> // for print debugging

SentPacket::SentPacket() {}

SentPacket::~SentPacket() {}

SentPacket::SentPacket(Packet* pack, Time time, Trace* t) {
  packet = *pack;
  time_sent = time;
  trace = t;
}

Time SentPacket::getTimeSent() { return time_sent; }

Packet* SentPacket::getPacket() { return &packet; }

int SentPacket::getSeqNo() { return trace->get_seqno(&packet); }

Monitor::Monitor() {}

Monitor::~Monitor() {delete &faultyList; delete &sentPacketTable; }

Monitor::Monitor(Trace* t, Bank* b, RouteCache** r_c) { 
  trace = t; 
  bank = b; 
  route_cache = r_c;
}

int Monitor::getSeqNo(Packet packet) { return trace->get_seqno(&packet); }

void Monitor::addPacketToCache(nsaddr_t address, Packet* packet, Time sending_time) {
  // if we dont have a list for this address node
  if(sentPacketTable.count(address) == 0) {
    // create one
    sentPacketTable[address] = new list<SentPacket*>;
  }
  // firstly check any current cached packets from this node
  // to see if they have expired
  checkPacketCache(address);

  // now add the new packet onto the end of this list
  list<SentPacket*>* l = sentPacketTable[address];
  l->push_back(new SentPacket(packet, sending_time, trace));
#ifdef MONITOR_DEBUG
  cout << "  [" << Scheduler::instance().clock() << "] Adding packet to cache of node #" << address << ". cache size=" << l->size() << endl << flush;
#endif
  
  // if using optimistic scheme, increment the next hop's
  // chipcount at this time (before they actually forward)
  if(OPTIMISTIC_SCHEME) {
    if(!bank->contains(address)) {
      bank->addNewEntry(address);
    }
    bank->incChipCount(address);
#ifdef MONITOR_DEBUG
    if(OPTIMISTIC_SCHEME) {
      cout << "  [" << Scheduler::instance().clock() << "] added to node #" << address << " chipcount, they now have $=" << bank->getChipCount(address) << endl << flush;
    }
#endif
  } 
}

void Monitor::flushCache(nsaddr_t address) {
  list<SentPacket*>* l = sentPacketTable[address];
  delete l;
}

void Monitor::handleTap(nsaddr_t sender_address, const Packet* packet) {
  // check that we have a cache of packets sent to this node,
  // hence we will be expecting them to forward our packets if they
  // require forwarding
  if(sentPacketTable.count(sender_address) == 0) {
    return;
  } 
  // iterate through the cached list for this node
  list<SentPacket*>* l = sentPacketTable[sender_address];
  list<SentPacket*>::iterator iter = l->begin();

  while(iter != l->end()) {
    SentPacket* sp = *iter;
    iter++;
    // check if the packet sequence numbers are equal
    if(sp->getSeqNo() == getSeqNo(*packet)) { 
      // if yes, then they must have forwarded our packet :-)
      // firstly, we remove it from our cache
      l->remove(sp);
      delete(sp);
      // secondly, if using the pessimistic scheme,
      // we increment their bank balance
      if(!OPTIMISTIC_SCHEME) {
	if(!bank->contains(sender_address)) {
	  bank->addNewEntry(sender_address);
	}
	bank->incChipCount(sender_address);
      }

#ifdef MONITOR_DEBUG
      if(!OPTIMISTIC_SCHEME) {
	cout << "  [" << Scheduler::instance().clock() << "] node #" << sender_address << " forwarded our packet. Removing it from our cache, they now have $" << bank->getChipCount(sender_address) << endl << flush;
      }else{
	cout << "  [" << Scheduler::instance().clock() << "] node #" << sender_address << " forwarded our packet. Removing it from our cache." << endl << flush;
      }
#endif

      // since they forwarded our packet, we register a positive event
      registerPositiveEvent(sender_address);
    }    
  } 
}

void Monitor::checkPacketCache(nsaddr_t address) {
  double time = Scheduler::instance().clock();
   // iterate through the cached list for this node
  list<SentPacket*>* l = sentPacketTable[address];
  list<SentPacket*>::iterator iter = l->begin();

  while(iter != l->end()) {
    SentPacket* sp = *iter;
    iter++;
    // first check if the cached packet's timeout has expired
    if(time - sp->getTimeSent() > PACKET_TIMEOUT) {
      // delete it from our cache
      l->remove(sp);
      delete(sp);
#ifdef MONITOR_DEBUG
      cout << "  [" << time << "] node #" << address << " has not forwarded quickly enough, deleting packet from cache" << endl << flush;
#endif
      // ****************** CODE TO ADD *********************** //
      // in further modules need to add code here to handle bad //
      // behaviour, as the node at sender_addresss has failed to //
      // forward a packet!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
      registerNegativeEvent(address);
      // *************** END OF CODE TO ADD ******************* //
    }
  }
}

bool Monitor::faultyListContains(nsaddr_t address) {
  list<nsaddr_t>::iterator iter = faultyList.begin();
  while(iter != faultyList.end()) {
    nsaddr_t entry = *iter;
    if(address == entry) {
      return true;
    }
    iter++;
  }

  return false;
}

// get a node's rating to see whether it is faulty or not
int Monitor::getNodeRating(nsaddr_t address) {
  BankEntry* entry = bank->getBankEntry(address);
  if(entry != NULL) {
    return entry->getRating();
  }
  return -1;
}

void Monitor::setNodeRating(nsaddr_t address, int val) {
  BankEntry* entry = bank->getBankEntry(address);
  if(entry != NULL) {
    // set their rating
    entry->setRating(val);
  }
}

void Monitor::registerPositiveEvent(nsaddr_t address) {
  BankEntry* entry = bank->getBankEntry(address);
  if(entry != NULL) {
    // increase their behaviour rating
    entry->incRating(INCREASE_RATING_AMOUNT);

#ifdef ROUTE_RANKER_DEBUG
    cout << "  [" << Scheduler::instance().clock() << "] registering positive event against node #" << address << ". Their new rating = " << entry->getRating() << endl << flush;
#endif
    
    // increase the # of packets they have forwarded for us
    entry->incTheirForwardingCount();
    
#ifdef ROUTE_RANKER_DEBUG
    cout << "  [" << Scheduler::instance().clock() << "] increasing forwarding count for  node #" << address << " :: theirForwardingCount = " << entry->getTheirForwardingCount() << endl << flush;  
#endif
  }
}

void Monitor::registerNegativeEvent(nsaddr_t address) {
  if(!bank->contains(address)) {
    bank->addNewEntry(address);
  }

  BankEntry* entry = bank->getBankEntry(address);
  if(entry != NULL) {
    // only register a negative event if 
    // 1) we have forwarded more traffic for them then they have for us
    // 2) we have NOT asked them to forward a number of packets which would have cost
    //    more than INITIAL_CHIPCOUNT, so we must still have some chips left with them.
    if(entry->getMyForwardingCount() >= entry->getTheirForwardingCount() ||
       (entry->getTheirForwardingCount()) * DECREMENT_AMOUNT < INITIAL_CHIPCOUNT) {
      
      if(entry->getRating() > FAULTY_RATING_THRESHOLD) {
	entry->decRating(DECREASE_RATING_AMOUNT);
      }
      
#ifdef ROUTE_RANKER_DEBUG
      cout << "  [" << Scheduler::instance().clock() << "] registering negative event against node #" << address << ". Their new rating = " << entry->getRating() << endl << flush;
#endif
      
      // check if the rating is below the min threshold
      if(entry->getRating() == FAULTY_RATING_THRESHOLD) {
	addNodeToFaultyList(address);
      }
    }
  }
}

// add a node to the faulty list
void Monitor::addNodeToFaultyList(nsaddr_t address) {
  if(!faultyListContains(address)) {
    // add it
#ifdef ROUTE_RANKER_DEBUG
    cout << "  [" << Scheduler::instance().clock() << "] node #" << address << " rating is below threshold. Adding them to the faulty list for this node." << endl << flush;
#endif
    faultyList.push_back(address);

    // now remove the route through the malicious node from the route_cache,
    // so that this node will perform RREQ again but it won't take a route
    // reply containing this malicious since, since it has been added to
    // the faulty list
    RouteCache* r_c = *route_cache;
    r_c->deleteRoute(address);
    // create a new second chance timer
    SecondChanceTimer* newTimer = new SecondChanceTimer(this, address);
    // make it fire after the given timeout period expires
    newTimer->resched(SEC_CHANCE_TIMEOUT_PERIOD);
  }
}

// remove a node from the faulty list
void Monitor::removeNodeFromFaultyList(nsaddr_t address) {
  if(faultyListContains(address)) {
    // remove it
#ifdef SECOND_CHANCE_MECHANISM_DEBUG
    cout << "  [" << Scheduler::instance().clock() << "] removing node #" << address << " from the faulty list for this node." << endl << flush;
#endif
    faultyList.remove(address);
  }
}

list<nsaddr_t>* Monitor::getFaultyList() {
  return &faultyList;
}

void SecondChanceTimer::expire(Event* e) {
  monitor->removeNodeFromFaultyList(node_address);
  monitor->setNodeRating(node_address, SEC_CHANCE_NEW_RATING);
  //monitor->flushCache(node_address);
  delete this;
}
