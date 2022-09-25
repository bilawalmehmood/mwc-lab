
/* ************************************************************
 *  Queue.h
 *  Modified from a queue implementation available at 
 *  http://www.josuttis.com/libbook/cont/Queue.hpp.html
 * ************************************************************/
#ifndef QUEUE_HPP
#define QUEUE_HPP

#include <deque>
#include <exception>

template <class T>
class FaultyTimeQueue {
  protected:
    deque<T> c;        // container for the elements

  public:
    /* exception class for pop() and top() with empty queue
     */
    class ReadEmptyQueue : public exception {
      public:
        virtual const char* what() const throw() {
            return "read empty queue";
        }
    };
  
    // number of elements
    typename deque<T>::size_type size() const {
        return c.size();
    }

    // is queue empty?
    bool empty() const {
        return c.empty();
    }

    // insert element into the queue
    void push (const T& elem) {
        c.push_back(elem);
    }

    // read element from the queue and return its value
    T pop () {
        if (c.empty()) {
            throw ReadEmptyQueue();
        }
        T elem(c.front());
        c.pop_front();
        return elem;
    }

    // return value of next element
    T& front () {
        if (c.empty()) {
            throw ReadEmptyQueue();
        }
        return c.front();
    }
};

#endif
