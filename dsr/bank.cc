#include "bank.h"

BankEntry::BankEntry() {}

BankEntry::~BankEntry() {}

BankEntry::BankEntry(double init, int initRat) {
  amount = init;
  rating = initRat;
  myForwardingCount = 0;
  theirForwardingCount = 0;
}

double BankEntry::getChipAmount() {
  return amount;
}

void BankEntry::incChipAmount(double val) {
  if(amount + val <= MAX_CHIPCOUNT) {
    amount += val;
  }
}

void BankEntry::decChipAmount(double val) {
  if(amount - val >= MIN_CHIPCOUNT) {
    amount -= val;
  }
}

int BankEntry::getRating() {
  return rating;
}

void BankEntry::setRating(int val) {
  rating = val;
}

void BankEntry::incRating(int val) {
  if(rating + val <= GOOD_RATING_THRESHOLD) {
    rating += val;
  }
}

void BankEntry::decRating(int val) {
  if(rating - val >= FAULTY_RATING_THRESHOLD) {
    rating -= val;
  }else {
    rating = FAULTY_RATING_THRESHOLD;
  }
}

void BankEntry::incMyForwardingCount() {
  myForwardingCount++;
}

void BankEntry::incTheirForwardingCount() {
  theirForwardingCount++;
}

double BankEntry::getMyForwardingCount() {
  return myForwardingCount;
}

double BankEntry::getTheirForwardingCount() {
  return theirForwardingCount;
}
  


Bank::Bank() {}

Bank::~Bank() { delete &bankTable; }

BankEntry* Bank::getBankEntry(nsaddr_t address) {
  if(contains(address)) {
    return &bankTable[address];
  }
  return NULL;
}

bool Bank::addNewEntry(nsaddr_t address) {
  if(!contains(address)) {
    bankTable[address] = BankEntry(INITIAL_CHIPCOUNT, INITIAL_RATING);
    return true;
  }
  return false;
}

bool Bank::removeEntry(nsaddr_t address) {
  if(contains(address)) {
    bankTable.erase(address); 
    return true;
  }
  return false;
}

bool Bank::contains(nsaddr_t address) {
  if(bankTable.count(address) != 0) {
    return true;
  }
  return false;
}

bool Bank::incChipCount(nsaddr_t address) {
  BankEntry* entry = getBankEntry(address);
  if(entry != NULL) {
    if(entry->getChipAmount() + INCREMENT_AMOUNT <= MAX_CHIPCOUNT) {
      entry->incChipAmount(INCREMENT_AMOUNT);
      return true;
    }
  }
  return false;
}

bool Bank::decChipCount(nsaddr_t address) {
  BankEntry* entry = getBankEntry(address);
  if(entry != NULL) {
    if(entry->getChipAmount() - DECREMENT_AMOUNT >= MIN_CHIPCOUNT) {
      entry->decChipAmount(DECREMENT_AMOUNT);
      return true;
    }
  }
  return false;
}

double Bank::getChipCount(nsaddr_t address) {
  BankEntry* entry = getBankEntry(address);
  if(entry != NULL) {
    return entry->getChipAmount();
  }
  return -1;
}

void Bank::incAllEntries(double amount) {
  map<nsaddr_t, BankEntry>::iterator iter = bankTable.begin();
  while(iter != bankTable.end()) {
    BankEntry* entry = &iter->second;
    if(entry->getChipAmount() + amount <= MAX_CHIPCOUNT) {
      // do not increment any entries on our faulty list
      if(entry->getRating() != FAULTY_RATING_THRESHOLD) {
	entry->incChipAmount(amount);
      }
    }
    iter++;
  }
}
