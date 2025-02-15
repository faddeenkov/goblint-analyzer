// PARAM: --set ana.activated[+] "localTraces"
#include <goblint.h>
#include <pthread.h>
#include <stdio.h>

int counter;
pthread_mutex_t lock;

void *f(void *arg) {
  pthread_mutex_lock(&lock);
  counter = -12;
  pthread_mutex_unlock(&lock);
}

void *g(void *arg) {
  pthread_t id_threadF;
  pthread_create(&id_threadF, NULL, &f, NULL);
}

void main() {
  pthread_mutex_init(&lock, NULL);
  pthread_t id_threadG;

  pthread_create(&id_threadG, NULL, &g, NULL);

  pthread_mutex_lock(&lock);
  counter = 3;
  pthread_mutex_unlock(&lock);

  pthread_join(id_threadG, NULL);

  pthread_mutex_destroy(&lock);
}