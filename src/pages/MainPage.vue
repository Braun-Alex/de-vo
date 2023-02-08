<template>
  <div class="q-pa-md">
    <q-card>
  <q-tabs
    v-model="tip"
    indicator-color="transparent"
    active-color="white"
    class="bg-teal text-grey-5 shadow-2"
    align="justify"
  >
    <q-tab name="edit" icon="edit" label="Як проголосовути" no-caps />
    <q-tab name="add_circle" icon="add_circle" label="Як створити голосування" no-caps />
  </q-tabs>
      <q-separator />
      <q-tab-panels v-model="tip" animated>
        <q-tab-panel name="edit">
          <q-stepper
            v-model="editStep"
            vertical
            color="primary"
            animated
          >
            <q-step
              :name="1"
              title="Під'єднайте гаманець MetaMask"
              active-icon="account_balance_wallet"
              color="teal"
              :done="editStep > 1"
            >
              Голосування он-чейн відбувається за допомогою смарт-контракту, який знаходиться
              на EVM-сумісному Layer-2 блокчейні Polygon у мережі Mainnet. Вам необхідно
              під'єднати Ваш гаманець MetaMask і обрати мережу Polygon Mainnet.

              <q-stepper-navigation>
                <q-btn @click="editStep = 2" push color="primary" label="Наступний крок" no-caps />
              </q-stepper-navigation>
            </q-step>

            <q-step
              :name="2"
              title="Оберіть голосування"
              icon="search"
              active-icon="search"
              color="teal"
              :done="editStep > 2"
            >
              Для того, щоб проголосувати, Вам необхідно обрати голосування, у якому Ви бажаєте взяти
              участь. Ви можете скористатися пошуком за ключовими словами, ідентифікатором чи
              EVM-адресою творця голосування, або обрати з-поміж наявних голосувань.

              <q-stepper-navigation>
                <q-btn @click="editStep = 3" push color="primary" label="Наступний крок" no-caps />
                <q-btn @click="editStep = 1" push color="warning" label="Повернутися" class="q-ml-sm" no-caps />
              </q-stepper-navigation>
            </q-step>

            <q-step
              :name="3"
              title="Оберіть бажаний варіант голосування"
              icon="task_alt"
              active-icon="task_alt"
              color="teal"
              :done="editStep > 3"
            >
              З-поміж наданих варіантів відповідей оберіть бажаний. Зверніть увагу, що
              можна обрати лише одну відповідь.

              <q-stepper-navigation>
                <q-btn @click="editStep = 4" push color="primary" label="Наступний крок" no-caps />
                <q-btn @click="editStep = 2" push color="warning" label="Повернутися" class="q-ml-sm" no-caps />
              </q-stepper-navigation>
            </q-step>

            <q-step
              :name="4"
              title="Підвердьте, що Ви впевнені у своєму виборі"
              icon="published_with_changes"
              active-icon="published_with_changes"
              color="teal"
              :done="editStep > 4"
            >
              Після того, як Ви визначилися із Вашою відповіддю, підтвердьте свій вибір.

              <q-stepper-navigation>
                <q-btn @click="editStep = 5" push color="primary" label="Наступний крок" no-caps />
                <q-btn @click="editStep = 3" push color="warning" label="Повернутися" class="q-ml-sm" no-caps />
              </q-stepper-navigation>
            </q-step>

            <q-step
              :name="5"
              title="Проголосуйте он-чейн"
              icon="verified"
              active-icon="verified"
              color="teal"
            >
              Після підтвердження Вами зробленого вибору Вам необхідно буде підписати транзакцію, яка
              полягає у виконанні методу "Vote" смарт-контракту стосовно тих голосування і вибору у
              ньому, які Ви обрали. Зверніть увагу, що Ви можете відхилити підписання транзакції.

              <q-stepper-navigation>
                <q-btn @click="editStep = 1" push color="primary" label="Пройти огляд ще раз" no-caps/>
                <q-btn @click="editStep = 4" push color="warning" label="Повернутися" class="q-ml-sm" no-caps/>
              </q-stepper-navigation>
            </q-step>
          </q-stepper>
        </q-tab-panel>

        <q-tab-panel name="add_circle">
          <div class="text-h6">Alarms</div>
          Lorem ipsum dolor sit amet consectetur adipisicing elit.
        </q-tab-panel>
      </q-tab-panels>
    </q-card>
  </div>
</template>

<script setup lang="ts">
import { ref, Ref } from 'vue'
const tip: Ref<string> = ref<string>('edit')
const editStep: Ref<number> = ref<number>(1)
</script>
