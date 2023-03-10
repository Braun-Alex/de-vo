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

        <q-input class="GNL__toolbar-input" outlined dense v-model="search"
                 :readonly="pollIdentifier !== '' || authorAddress !== ''"
                 color="teal" @keyup.enter="searchPressed = !searchPressed"
                 placeholder="Знайти за назвою або запитанням">
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
              <q-menu anchor="bottom end" self="top end"
              transition-show="jump-down"
              transition-hide="jump-up">
                <div class="q-pa-md" style="width: 400px">
                  <div class="text-body2 text-grey q-mb-md">
                    Знайти за ідентифікатором або EVM-адресою
                  </div>

                  <div class="row items-center">
                    <div class="col-3 text-subtitle2 text-grey">
                      Ідентифікатор голосування
                    </div>
                    <div class="col-9 q-pl-md">
                      <q-input outlined dense :disable="search !== '' || authorAddress !== ''" v-model="pollIdentifier" />
                    </div>

                    <div class="col-3 text-subtitle2 text-grey">
                      EVM-адреса автора
                    </div>
                    <div class="col-9 q-pl-md">
                      <q-input outlined dense :disable="search !== '' || pollIdentifier !== ''" v-model="authorAddress" />
                    </div>

                    <div class="col-12 q-pt-lg row justify-end">
                      <q-btn flat dense no-caps color="primary" size="md" style="min-width: 68px;"
                             @click="searchPressed = !searchPressed" label="Знайти" v-close-popup />
                      <q-btn flat dense no-caps color="warning" size="md" style="min-width: 68px;"
                             @click="onClear" label="Відкликати" v-close-popup />
                    </div>
                  </div>
                </div>
              </q-menu>
            </q-btn>
          </template>
        </q-input>

        <q-space />

        <div class="q-gutter-sm row items-center no-wrap">
          <q-btn glossy style="background: #FF0080; color: white"
                 flat :label="walletConnected ?
                   String(walletAddress.slice(0, 5) + '...' + walletAddress.slice(-4))
                   : 'Під\'єднати гаманець MetaMask'"
                 :icon="walletConnected ? '' : 'account_balance_wallet'"
                 :icon-right="walletConnected ? '' : 'account_balance_wallet'"
                 @click="walletConnected ? disconnectWallet(): connectWallet()" no-caps>
          </q-btn>
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      class="bg-white"
      width="280"
    >
      <q-scroll-area class="fit">
        <q-list padding class="text-grey-8">

          <q-item class="GNL__drawer-item" to="/voting" v-ripple clickable>
            <q-item-section avatar>
              <q-icon name="edit" />
            </q-item-section>
            <q-item-section>
              <q-item-label>Проголосувати</q-item-label>
            </q-item-section>
          </q-item>

          <q-separator inset class="q-my-sm" />

          <q-item class="GNL__drawer-item" to="/creating" v-ripple clickable>
            <q-item-section avatar>
              <q-icon name="add_circle" />
            </q-item-section>
            <q-item-section>
              <q-item-label>Створити голосування</q-item-label>
            </q-item-section>
          </q-item>

          <q-separator inset class="q-my-sm" />

          <q-item class="GNL__drawer-item" to="/" v-ripple clickable>
            <q-item-section avatar>
              <q-icon name="preview" />
            </q-item-section>
            <q-item-section>
              <q-item-label>На головну</q-item-label>
            </q-item-section>
          </q-item>

        </q-list>
      </q-scroll-area>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { ref, provide, Ref } from 'vue'
import { useQuasar, QSpinnerGears } from 'quasar'
import { ethers } from 'ethers'
const $q = useQuasar()
const leftDrawerOpen: Ref<boolean> = ref<boolean>(false)
const search: Ref<string> = ref<string>('')
const pollIdentifier: Ref<string> = ref<string>('')
const authorAddress: Ref<string> = ref<string>('')
const walletConnected: Ref<boolean> = ref<boolean>(false)
const walletAddress: Ref<string> = ref<string>('')
const searchPressed: Ref<boolean> = ref<boolean>(false)

if ($q.localStorage.getItem('Wallet connected') != null) {
  walletConnected.value = $q.localStorage.getItem('Wallet connected') as boolean
}
if ($q.localStorage.getItem('Wallet address') != null) {
  walletAddress.value = $q.localStorage.getItem('Wallet address') as string
}

provide('walletConnected', walletConnected)
provide('search', search)
provide('pollIdentifier', pollIdentifier)
provide('authorAddress', authorAddress)
provide('searchPressed', searchPressed)

function onClear () {
  search.value = ''
  pollIdentifier.value = ''
  authorAddress.value = ''
}

function toggleLeftDrawer () {
  leftDrawerOpen.value = !leftDrawerOpen.value
}

function connectWallet () {
  // @ts-expect-error Window.ethers not TS
  if (typeof window.ethereum !== 'undefined') {
    $q.loading.show({
      spinner: QSpinnerGears,
      message: 'Під\'єднання гаманця...'
    })
    // @ts-expect-error Window.ethers not TS
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    provider.send('eth_requestAccounts', []).then(() => {
      $q.notify({
        type: 'positive',
        message: 'Гаманець успішно під\'єднано'
      })
      const signer = provider.getSigner()
      signer.getAddress().then((address) => {
        walletAddress.value = address
        walletConnected.value = true
        $q.localStorage.set('Wallet address', walletAddress.value)
        $q.localStorage.set('Wallet connected', walletConnected.value)
      })
    }).catch(() => {
      $q.notify({
        type: 'negative',
        message: 'Запит на під\'єднання було відхилено'
      })
    }).finally(() => {
      $q.loading.hide()
    })
  } else {
    $q.notify({
      type: 'negative',
      message: 'MetaMask не встановлено'
    })
  }
}

function disconnectWallet () {
  walletConnected.value = false
  walletAddress.value = ''
  $q.localStorage.set('Wallet address', walletConnected.value)
  $q.localStorage.set('Wallet connected', walletAddress.value)
  $q.notify({
    type: 'info',
    message: 'Гаманець від\'єднано'
  })
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
