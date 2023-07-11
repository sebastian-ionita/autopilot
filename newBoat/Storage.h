#include <EEPROMex.h>

class Storage
{
  public:
  void store(int address, double data);
  double read(int address);  
};
