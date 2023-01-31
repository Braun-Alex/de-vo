<template>
  <div class="q-pa-md">

    <q-form
      @submit="onSubmit"
      @reset="onReset"
      class="q-gutter-md text-center"
    >
      <q-input
        outlined
        v-model="title"
        label="Назва опитування"
        hint="Назва має відображати зміст опитування"
        clearable
        counter
        lazy-rules
        autogrow
        maxlength="100"
        :rules="[
          val => val && val.length > 0 || 'Поле назви опитування не може бути порожньою',
          val => val.length >= 2 || 'Назва опитування не може бути такою короткою'
          ]"
      />

      <q-input
        outlined
        v-model="question"
        label="Запитання"
        hint="Запитання, яке поставлено на порядок голосування"
        clearable
        counter
        lazy-rules
        autogrow
        maxlength="100"
        :rules="[
          val => val && val.length > 0 || 'Поле запитання до опитування не може бути порожнім',
          val => val.length >= 6 || 'Запитання до опитування не може бути таким коротким'
        ]"
      />

      <q-select
        label="Створіть список варіантів відповідей в опитуванні"
        hint="Учасник голосування матиме можливість обрати бажаний варіант зі списку"
        outlined
        v-model="proposals"
        use-input
        use-chips
        multiple
        hide-dropdown-icon
        input-debounce="0"
        @new-value="createProposal"
        :rules="[
          val => val && val.length > 0 || 'Список варіантей відповідей не може бути порожнім',
          val => val.length > 1 || 'Список має складатися принаймні з двох варіантей відповідей'
        ]"
      />

      <q-input
        outlined
        type="number"
        v-model="duration"
        label="Тривалість опитування"
        hint="Голосування триватиме вказану кількість годин"
        clearable
        lazy-rules
        autogrow
        :rules="[
          val => val !== null && val !== '' || 'Поле тривалості опитування не може бути порожньою',
          val => val > 0 && durationInSeconds % 3600 === 0 || 'Поле тривалості опитування має бути додатнім цілим числом',
          val => val.toString().lastIndexOf('.') === -1 || 'Поле тривалості опитування не може містити крапки'
        ]"
      />

      <q-toggle v-model="accept"
                label="Я погоджуюся з тим, що голосування буде створено он-чейн" />

      <div>
        <q-btn label="Створити голосування" type="submit" color="primary"/>
        <q-btn label="Відізвати зміни" type="reset" color="primary" flat class="q-ml-sm" />
      </div>
    </q-form>

  </div>
</template>

<script setup lang="ts">
import { ref, Ref, inject, computed, ComputedRef } from 'vue'
import { useQuasar, format, QSpinnerGears } from 'quasar'
import { ethers } from 'ethers'
import { abi } from 'src/Ballot.json'
const $q = useQuasar()
const title: Ref<null> = ref(null)
const question: Ref<null> = ref(null)
const proposals: Ref<string[] | null> = ref(null)
const duration: Ref<null> = ref(null)
const durationInSeconds: ComputedRef<number | null> = computed(() => {
  return duration.value === null ? null : 3600 * duration.value
})
const accept = ref(false)
const walletConnected = inject<Ref<boolean>>('walletConnected') as Ref<boolean>
const contractAddress = process.env.VUE_APP_BALLOT_CONTRACT
const contractMutated = inject<Ref<boolean>>('contractMutated') as Ref<boolean>

function onSubmit () {
  if (accept.value !== true) {
    $q.notify({
      type: 'negative',
      message: 'Вам потрібно надати згоду'
    })
  } else if (!walletConnected.value) {
    $q.notify({
      type: 'negative',
      message: 'Вам потрібно під\'єднати гаманець MetaMask для створення голосування он-чейн'
    })
  } else {
    // @ts-expect-error Window.ethers not TS
    if (typeof window.ethereum !== 'undefined') {
      // @ts-expect-error Window.ethers not TS
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const contract = new ethers.Contract(
        contractAddress as string,
        abi,
        signer
      )
      $q.loading.show({
        spinner: QSpinnerGears,
        message: 'Підписання транзакції...'
      })
      try {
        contract.create(
          title.value,
          question.value,
          proposals.value,
          durationInSeconds.value).then((transaction: any) => {
          $q.loading.hide()
          $q.loading.show({
            spinner: QSpinnerGears,
            message: 'Обробка транзакції...'
          })
          transaction.wait().then(() => {
            $q.notify({
              type: 'positive',
              icon: 'cloud_done',
              message: 'Голосування було успішно створено он-чейн'
            })
            contractMutated.value = true
            contractMutated.value = false
          }).catch((error: any) => {
            $q.notify({
              type: 'negative',
              message: 'У процесі обробки транзакції виникла помилка: ' + error.message
            })
          }).finally(() => {
            $q.loading.hide()
          })
        }).catch(() => {
          $q.loading.hide()
          $q.notify({
            type: 'negative',
            message: 'Підписання транзакції було відхилено'
          })
        })
      } catch (error: any) {
        $q.notify({
          type: 'negative',
          message: 'Виникла помилка у створенні голосування: ' + error.message
        })
      }
    } else {
      $q.notify({
        type: 'negative',
        message: 'MetaMask не встановлено'
      })
    }
  }
}

function onReset () {
  title.value = null
  question.value = null
  proposals.value = null
  duration.value = null
  accept.value = false
}

function createProposal (val: string, done: any) {
  done(format.capitalize(val.toLowerCase()), 'add-unique')
}
</script>
