<?php

namespace Drupal\playerconnect\Plugin\rest\resource;

use Drupal\rest\ResourceResponse;
use Drupal\rest\ResourceInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Drupal\node\Entity\Node;
use Drupal\Core\Entity\EntityStorageException;
use Drupal\Core\Cache\CacheableMetadata;

/**
 * Provides a resource to manage Player nodes.
 *
 * @RestResource(
 *   id = "player_resource",
 *   label = @Translation("Player Resource"),
 *   uri_paths = {
 *     "canonical" = "/api/player",
 *     "create" = "/api/player",
 *     "update" = "/api/player/{id}"
 *   }
 * )
 */
class PlayerResource implements ResourceInterface {

  /**
   * Responds to GET requests.
   */
  public function get($id = NULL) {
    if ($id) {
      $node = Node::load($id);
      if ($node) {
        return new ResourceResponse($node);
      }
      throw new NotFoundHttpException();
    }
    // Return all player nodes if no ID is provided.
    $query = \Drupal::entityQuery('node')
      ->condition('type', 'player');
    $nids = $query->execute();
    $nodes = Node::loadMultiple($nids);
    return new ResourceResponse($nodes);
  }

  /**
   * Responds to POST requests.
   */
  public function post(Request $request) {
    $data = json_decode($request->getContent(), TRUE);
    $title = $data['playerconnect_name'];
    $current_score = $data['playerconnect_current_score'];
    $info = $data['playerconnect_info'];

    // Check if a player node with the same title exists.
    $existing_nodes = \Drupal::entityQuery('node')
      ->condition('type', 'player')
      ->condition('title', $title)
      ->execute();

    if (!empty($existing_nodes)) {
      // Update existing player node.
      $node = Node::load(reset($existing_nodes));
      $node->set('playerconnect_current_score', $current_score);
      $node->set('playerconnect_info', $info);
      if ($current_score > $node->get('playerconnect_high_score')->value) {
        $node->set('playerconnect_high_score', $current_score);
      }
      $node->save();
      return new ResourceResponse($node, 200);
    } else {
      // Create a new player node.
      $node = Node::create([
        'type' => 'player',
        'title' => $title,
        'playerconnect_current_score' => $current_score,
        'playerconnect_high_score' => $current_score,
        'playerconnect_info' => $info,
      ]);
      $node->save();
      return new ResourceResponse($node, 201);
    }
  }

  /**
   * Responds to PATCH requests.
   */
  public function patch($id, Request $request) {
    $node = Node::load($id);
    if (!$node) {
      throw new NotFoundHttpException();
    }

    $data = json_decode($request->getContent(), TRUE);
    if (isset($data['playerconnect_current_score'])) {
      $current_score = $data['playerconnect_current_score'];
      $node->set('playerconnect_current_score', $current_score);
      if ($current_score > $node->get('playerconnect_high_score')->value) {
        $node->set('playerconnect_high_score', $current_score);
      }
    }
    if (isset($data['playerconnect_info'])) {
      $node->set('playerconnect_info', $data['playerconnect_info']);
    }
    $node->save();
    return new ResourceResponse($node, 200);
  }
}