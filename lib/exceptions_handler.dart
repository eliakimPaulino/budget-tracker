
double exceptionHandler(double currentbalance, double amount) {
  double result = currentbalance - amount;
  if (result < 0) result = 0;
  return result;
}

double excepetionHandler2(double currentbalance, double amount) {
  return currentbalance == 0 ? 0 : currentbalance + amount;
}
