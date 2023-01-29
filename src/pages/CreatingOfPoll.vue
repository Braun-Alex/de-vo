<template>
  <div class="q-pa-md">

    <q-form
      @submit="onSubmit"
      @reset="onReset"
      class="q-gutter-md text-center"
    >
      <q-input
        outlined
        v-model="name"
        label="Назва опитування"
        hint="Назва має відображати зміст опитування"
        clearable
        counter
        lazy-rules
        autogrow
        maxlength="100"
        :rules="[
          val => val && val.length > 0 || 'Назва опитування не може бути порожньою'
          ]"
      />

      <q-input
        outlined
        v-model="age"
        label="Запитання"
        hint="Запитання, яке поставлено на порядок голосування"
        clearable
        counter
        lazy-rules
        autogrow
        maxlength="100"
        :rules="[
          val => val && val.length > 0 || 'Запитання до опитування не може бути порожнім'
        ]"
      />

      <q-select
        label="Створіть варіанти відповідей в опитуванні"
        outlined
        v-model="proposals"
        use-input
        use-chips
        multiple
        hide-dropdown-icon
        input-debounce="0"
        @new-value="createProposal"
      />

      <q-toggle v-model="accept" label="Я погоджуюся з тим, що голосування буде створено он-чейн" />

      <div>
        <q-btn label="Створити" type="submit" color="primary"/>
        <q-btn label="Відізвати" type="reset" color="primary" flat class="q-ml-sm" />
      </div>
    </q-form>

  </div>
</template>

<script setup lang="ts">
import { ref, Ref } from 'vue'
import { useQuasar } from 'quasar'
const $q = useQuasar()
const name = ref(null)
const age = ref(null)
const accept = ref(false)
const proposals: Ref<string[] | null> = ref(null)
function onSubmit () {
  if (accept.value !== true) {
    $q.notify({
      color: 'red-5',
      textColor: 'white',
      icon: 'warning',
      message: 'You need to accept the license and terms first'
    })
  } else {
    $q.notify({
      color: 'green-4',
      textColor: 'white',
      icon: 'cloud_done',
      message: 'Submitted'
    })
  }
}

function onReset () {
  name.value = null
  age.value = null
  accept.value = false
  $q.notify({
    type: 'positive',
    message: (proposals.value as string[]).toString()
  })
}

function createProposal (val: any, done: any) {
  done(val, 'add-unique')
}
</script>
