<template>
  <q-layout view="hHh lpR fFf" class="bg-grey-1">
    <q-header elevated class="bg-white text-grey-8" height-hint="64">
      <q-toolbar class="GNL__toolbar">
        <q-btn
          flat
          dense
          round
          @click="toggleLeftDrawer"
          aria-label="Menu"
          icon="menu"
          class="q-mr-sm"
        />

        <q-toolbar-title v-if="$q.screen.gt.xs" shrink class="row items-center no-wrap">
          <span class="q-ml-sm">DeVo</span>
          <q-icon name="how_to_vote" color="teal" />
        </q-toolbar-title>

        <q-space />

        <q-input class="GNL__toolbar-input" outlined dense v-model="search" color="bg-grey-7 shadow-1" placeholder="Знайти голосування">
          <template v-slot:prepend>
            <q-icon v-if="search === ''" name="search" />
            <q-icon v-else name="clear" class="cursor-pointer" @click="search = ''" />
          </template>
          <template v-slot:append>
            <q-btn
              flat
              dense
              round
              aria-label="Menu"
              icon="arrow_drop_down"
            >
              <q-menu anchor="bottom end" self="top end">
                <div class="q-pa-md" style="width: 400px">
                  <div class="text-body2 text-grey q-mb-md">
                    Введіть ідентифікатор голосування або EVM-адресу автора
                  </div>

                  <div class="row items-center">
                    <div class="col-3 text-subtitle2 text-grey">
                      Ідентифікатор голосування
                    </div>
                    <div class="col-9 q-pl-md">
                      <q-input dense :disable="authorAddress !== ''" v-model="pollIdentifier" />
                    </div>

                    <div class="col-3 text-subtitle2 text-grey">
                      EVM-адреса автора
                    </div>
                    <div class="col-9 q-pl-md">
                      <q-input dense :disable="pollIdentifier !== ''" v-model="authorAddress" />
                    </div>

                    <div class="col-12 q-pt-lg row justify-end">
                      <q-btn flat dense no-caps color="grey-7" size="md" style="min-width: 68px;" label="Search" v-close-popup />
                      <q-btn flat dense no-caps color="grey-7" size="md" style="min-width: 68px;" @click="onClear" label="Clear" v-close-popup />
                    </div>
                  </div>
                </div>
              </q-menu>
            </q-btn>
          </template>
        </q-input>

        <q-space />

        <div class="q-gutter-sm row items-center no-wrap">
          <q-btn style="background: #FF0080; color: white"
                 flat :label="walletConnected ? 'Привіт' : 'Підключити MetaMask'"
                 :icon="walletConnected ? '' : 'account_balance_wallet'"
                 :icon-right="walletConnected ? '' : 'account_balance_wallet'"
                 :loading="loading" @click="simulateProgress()" no-caps>
          </q-btn>
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      class="bg-white"
      :width="280"
    >
      <q-scroll-area class="fit">
        <q-list padding class="text-grey-8">
          <q-item class="GNL__drawer-item" v-ripple v-for="link in polls" :key="link.text" clickable>
            <q-item-section avatar>
              <q-icon :name="link.icon" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{ link.text }}</q-item-label>
            </q-item-section>
          </q-item>

          <q-separator inset class="q-my-sm" />

          <q-item class="GNL__drawer-item" v-ripple v-for="link in notations" :key="link.text" clickable>
            <q-item-section avatar>
              <q-icon :name="link.icon" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{ link.text }}</q-item-label>
            </q-item-section>
          </q-item>

          <q-separator inset class="q-my-sm" />

          <q-item class="GNL__drawer-item" v-ripple v-for="link in details" :key="link.text" clickable>
            <q-item-section>
              <q-item-label>{{ link.text }} <q-icon v-if="link.icon" :name="link.icon" /></q-item-label>
            </q-item-section>
          </q-item>

          <div class="q-mt-md">
            <div class="flex flex-center q-gutter-xs">
              <a class="GNL__drawer-footer-link" href="javascript:void(0)" aria-label="Privacy">Політика конфіденційності</a>
              <span> · </span>
              <a class="GNL__drawer-footer-link" href="javascript:void(0)" aria-label="Terms">Положення використання</a>
              <span> · </span>
              <a class="GNL__drawer-footer-link" href="javascript:void(0)" aria-label="About">Про автора</a>
            </div>
          </div>
        </q-list>
      </q-scroll-area>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const leftDrawerOpen = ref<boolean>(false)
const search = ref<string>('')
const pollIdentifier = ref<string>('')
const authorAddress = ref<string>('')
const loading = ref<boolean>(false)
const walletConnected = ref<boolean>(false)
interface Link {
  icon: string,
  text: string
}
const polls = ref<Array<Link>>(
  [
    { icon: 'add_circle', text: 'Створити голосування' },
    { icon: 'edit', text: 'Отримати статистичні дані' }
  ])
const notations = ref<Array<Link>>(
  [
    { icon: 'flag', text: 'Повідомити про порушення авторських прав' },
    { icon: 'account_tree', text: 'Про сайт' }
  ])
const details = ref<Array<Link>>(
  [
    { icon: '', text: 'Зворотній зв\'язок' },
    { icon: 'open_in_new', text: 'Туторіал' }
  ])
function simulateProgress () {
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 3000)
}
function onClear () {
  pollIdentifier.value = ''
  authorAddress.value = ''
}
function toggleLeftDrawer () {
  leftDrawerOpen.value = !leftDrawerOpen.value
}
</script>

<style lang="sass">
.GNL
  &__toolbar
    height: 64px
  &__toolbar-input
    width: 55%
  &__drawer-item
    line-height: 24px
    border-radius: 0 24px 24px 0
    margin-right: 12px
    .q-item__section--avatar
      .q-icon
        color: #5f6368
    .q-item__label
      color: #3c4043
      letter-spacing: .01785714em
      font-size: .875rem
      font-weight: 500
      line-height: 1.25rem
  &__drawer-footer-link
    color: inherit
    text-decoration: none
    font-weight: 500
    font-size: .75rem
    &:hover
      color: #000
</style>
