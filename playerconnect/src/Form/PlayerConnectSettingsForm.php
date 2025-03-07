<?php

namespace Drupal\playerconnect\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

class PlayerConnectSettingsForm extends ConfigFormBase {

  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames() {
    return ['playerconnect.settings'];
  }

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'playerconnect_settings_form';
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    $config = $this->config('playerconnect.settings');

    $form['passkey'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Passkey'),
      '#description' => $this->t('Enter the passkey for securing the RESTful connection.'),
      '#default_value' => $config->get('passkey'),
      '#required' => TRUE,
    ];

    return parent::buildForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    $this->config('playerconnect.settings')
      ->set('passkey', $form_state->getValue('passkey'))
      ->save();

    parent::submitForm($form, $form_state);
  }

}