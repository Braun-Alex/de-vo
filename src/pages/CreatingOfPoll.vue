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
          val => val > 0 || 'Поле тривалості опитування має бути додатнім цілим числом'
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
import { ref, Ref, inject } from 'vue'
import { useQuasar, format } from 'quasar'
const $q = useQuasar()
const title = ref(null)
const question = ref(null)
const proposals: Ref<string[] | null> = ref(null)
const duration = ref(null)
const accept = ref(false)
const walletConnected = ref(false)

inject('walletConnected', walletConnected)

function onSubmit () {
  if (accept.value !== true) {
    $q.notify({
      color: 'red-5',
      textColor: 'white',
      icon: 'warning',
      message: 'Вам потрібно надати згоду'
    })
  } else if (!walletConnected.value) {
    $q.notify({
      color: 'red-5',
      textColor: 'white',
      icon: 'warning',
      message: 'Вам потрібно під\'єднати гаманець MetaMask для створення голосування он-чейн'
    })
  } else {
    $q.notify({
      color: 'green-3',
      textColor: 'white',
      icon: 'cloud_done',
      message: 'Відправлено'
    })
  }
}

function onReset () {
  title.value = null
  question.value = null
  proposals.value = null
  accept.value = false
}

function createProposal (val: string, done: any) {
  done(format.capitalize(val.toLowerCase()), 'add-unique')
}
</script>
