<?php

namespace Drupal\playerconnect\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\node\Entity\Node;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class PlayerController extends ControllerBase {

  public function createPlayer(Request $request) {
    $data = json_decode($request->getContent(), TRUE);
    $provided_passkey = $data['passkey'] ?? NULL;

    // Get the configured passkey.
    $config = $this->config('playerconnect.settings');
    $configured_passkey = $config->get('passkey');

    // Check if the passkey is valid.
    if ($provided_passkey !== $configured_passkey) {
      throw new AccessDeniedHttpException('Invalid passkey.');
    }

    $playerName = $data['playerconnect_name'] ?? NULL;
    $currentScore = $data['playerconnect_current_score'] ?? NULL;
    $playerInfo = $data['playerconnect_info'] ?? NULL;

    if (!$playerName) {
      return new JsonResponse(['error' => 'Player name is required.'], 400);
    }

    // Check if a player node with the same title exists.
    $existingPlayer = $this->getPlayerByName($playerName);
    if ($existingPlayer) {
      return $this->updatePlayer($existingPlayer, $currentScore, $playerInfo);
    } else {
      return $this->createNewPlayer($playerName, $currentScore, $playerInfo);
    }
  }

  private function getPlayerByName($playerName) {
    $query = \Drupal::entityQuery('node')
      ->condition('type', 'player')
      ->condition('title', $playerName)
      ->range(0, 1)
      ->accessCheck(FALSE); // Explicitly set access check to FALSE
    $nids = $query->execute();

    return !empty($nids) ? Node::load(reset($nids)) : NULL;
  }

  private function updatePlayer(Node $playerNode, $currentScore, $playerInfo) {
    $playerNode->set('playerconnect_current_score', $currentScore);
    $playerNode->set('playerconnect_info', $playerInfo);

    // Update high score if current score is higher.
    $highScore = $playerNode->get('playerconnect_high_score')->value;
    if ($currentScore > $highScore) {
      $playerNode->set('playerconnect_high_score', $currentScore);
    }

    $playerNode->save();
    return new JsonResponse(['status' => 'Player updated successfully.'], 200);
  }

  private function createNewPlayer($playerName, $currentScore, $playerInfo) {
    $playerNode = Node::create([
      'type' => 'player',
      'title' => $playerName,
      'playerconnect_current_score' => $currentScore,
      'playerconnect_high_score' => $currentScore,
      'playerconnect_info' => $playerInfo,
    ]);
    $playerNode->save();
    return new JsonResponse(['status' => 'Player created successfully.'], 201);
  }

}