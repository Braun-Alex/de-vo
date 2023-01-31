<template>
  <div class="q-pa-md q-gutter-md">
    <q-btn @click="retrievePolls()" no-caps>
      Retrieve polls
    </q-btn>
    <q-list bordered separator class="rounded-borders">

      <q-item v-for="poll in allPolls" :key="poll.whenCreated">
        <q-item-section avatar top>
          <q-icon name="account_tree" color="black" />
        </q-item-section>

        <q-item-section top class="col-2 gt-sm">
          <q-item-label class="q-mt-sm">
            {{ String(poll.author.slice(0, 5) + '...' + poll.author.slice(-4)) }}
            <q-tooltip delay="1500">EVM-адреса автора</q-tooltip>
          </q-item-label>
        </q-item-section>

        <q-item-section top class="col-2 gt-sm">
          <q-item-label class="q-mt-sm">
            {{ date.formatDate(poll.whenCreated, 'D.MM.YYYYTHH:mm:ss') }}
            <q-tooltip delay="1500">Дата створення</q-tooltip>
          </q-item-label>
        </q-item-section>

        <q-item-section top>
          <q-item-label lines="1">
            <span class="text-weight-medium">
              {{ poll.title }}
              <q-tooltip delay="1500">Назва голосування</q-tooltip>
            </span>
          </q-item-label>
          <q-item-label caption lines="1">
            {{ poll.question }}
            <q-tooltip delay="1500">Поставлене запитання</q-tooltip>
          </q-item-label>
          <q-item-label lines="1" class="q-mt-xs text-body2 text-weight-bold text-primary">
            <span>{{ getPollTime(poll.whenCreated, poll.duration) }}</span>
            <q-tooltip delay="1500">Скільки ще триватиме голосування</q-tooltip>
          </q-item-label>
        </q-item-section>

        <q-item-section top side>
          <div class="text-grey-8 q-gutter-xs">
            <q-btn round icon="ballot">
              <q-tooltip>Проголосувати</q-tooltip>
            </q-btn>
          </div>
        </q-item-section>
      </q-item>

    </q-list>
  </div>
</template>

<script setup lang="ts">
import { ref, inject, Ref, watch } from 'vue'
import { useQuasar, date } from 'quasar'
import { ethers } from 'ethers'
import { abi } from 'src/Ballot.json'

interface Poll {
  title: string,
  question: string,
  proposals: string[],
  author: string,
  whenCreated: number,
  duration: number
}

const $q = useQuasar()
const contractAddress = process.env.VUE_APP_BALLOT_CONTRACT
const allPolls = ref<Poll[]>([])

const contractMutated: Ref<boolean> = inject('contractMutated') as Ref<boolean>

watch(contractMutated, retrievePolls)

async function retrievePolls () {
  allPolls.value = []
  // @ts-expect-error Window.ethers not TS
  if (typeof window.ethereum !== 'undefined') {
    // @ts-expect-error Window.ethers not TS
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const contract = new ethers.Contract(
      contractAddress as string,
      abi,
      provider
    )
    try {
      const data = await contract.getAllPolls()
      data.forEach((poll: any) => {
        allPolls.value.push({
          title: poll.title,
          question: poll.question,
          proposals: poll.proposals,
          author: poll.author,
          whenCreated: poll.whenCreated * 1000,
          duration: poll.duration
        })
      })
    } catch (error: any) {
      $q.notify({
        type: 'negative',
        message: 'Виникла помилка відображення списку голосувань: ' + error.message
      })
    }
  }
}

function getPollTime (whenCreated: number, duration: number) {
  const dateOfCreating = new Date(whenCreated)
  const dateOfClosing = date.addToDate(dateOfCreating, { seconds: duration })
  const currentDate = Date.now()
  if (currentDate > dateOfClosing.getTime()) return 'Завершено'
  let answer = 'Триватиме ще '
  const differenceInHours = date.getDateDiff(dateOfClosing, currentDate, 'hours') - 1
  if (differenceInHours > 0) {
    const time = ' більше ' + differenceInHours
    answer += differenceInHours % 10 === 1 ? time +
      ' години' : time + ' годин'
  } else {
    const differenceInMinutes = date.getDateDiff(dateOfClosing, currentDate, 'minutes') - 1
    if (differenceInMinutes > 0) {
      answer += differenceInHours % 10 === 1 ? differenceInMinutes +
        ' хвилину' : differenceInMinutes + ' хвилин'
    } else {
      const differenceInSeconds = date.getDateDiff(dateOfClosing, currentDate, 'seconds') - 1
      answer += differenceInSeconds % 10 === 1 ? differenceInSeconds +
        ' секунду' : differenceInSeconds + ' секунд'
    }
  }
  return answer
}
</script>
