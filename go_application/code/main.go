package main

import (
    "fmt"
    "log"
    "os"
    "os/signal"
    "syscall"

    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/fields"
    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/rest"
    "k8s.io/client-go/tools/cache"
)

func main() {
    // Create in-cluster config
    config, err := rest.InClusterConfig()
    if err != nil {
        log.Fatalf("Failed to create in-cluster config: %v", err)
    }

    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        log.Fatalf("Failed to create Kubernetes client: %v", err)
    }

    // Watch all pods across all namespaces
    lw := cache.NewListWatchFromClient(
        clientset.CoreV1().RESTClient(),
        "pods",
        metav1.NamespaceAll,
        fields.Everything(),
    )

    _, controller := cache.NewInformer(
        lw,
        &corev1.Pod{},
        0,
        cache.ResourceEventHandlerFuncs{
            AddFunc: func(obj interface{}) {
                pod := obj.(*corev1.Pod)
                log.Printf("[CREATED] Pod %s/%s", pod.Namespace, pod.Name)
            },
            UpdateFunc: func(oldObj, newObj interface{}) {
                pod := newObj.(*corev1.Pod)
                log.Printf("[UPDATED] Pod %s/%s", pod.Namespace, pod.Name)
            },
            DeleteFunc: func(obj interface{}) {
                pod := obj.(*corev1.Pod)
                log.Printf("[DELETED] Pod %s/%s", pod.Namespace, pod.Name)
            },
        },
    )

    stopCh := make(chan struct{})
    defer close(stopCh)

    go controller.Run(stopCh)

    // Graceful shutdown
    sigCh := make(chan os.Signal, 1)
    signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
    <-sigCh
    fmt.Println("Shutting down pod monitor...")
}