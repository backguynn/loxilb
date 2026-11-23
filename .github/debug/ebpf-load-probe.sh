#!/bin/bash
# Temporary debug probe: start loxilb the way cicd/common.sh does, but keep
# its stderr (libbpf prints the verifier log there) and watch what happens.
# Usage: ebpf-load-probe.sh <image-ref> <out-dir>

set -u

IMG="$1"
OUT="$2"
NAME=llb1

mkdir -p "$OUT/varlog"

since() {
  awk -v a="$(date +%s.%N)" -v b="$T0" 'BEGIN { printf "%6.1f", a - b }'
}

state() {
  docker exec "$NAME" bash -c '
    if [ -f /tmp/loxilb.exit ]; then p="dead(rc=$(cat /tmp/loxilb.exit))"; else p=alive; fi
    if (exec 3<>/dev/tcp/127.0.0.1/11111) 2>/dev/null; then a=api-up; else a=api-down; fi
    e=$(tc filter show dev eth0 ingress 2>/dev/null | grep -c tc_packet_func)
    l=$(tc filter show dev llb0 ingress 2>/dev/null | grep -c tc_packet_func)
    s=$(wc -c < /tmp/loxilb.stderr 2>/dev/null)
    echo "$p $a eth0-hook=$e llb0-hook=$l stderr-bytes=$s"'
}

watch() {
  local secs="$1" dead=0
  for _ in $(seq "$secs"); do
    st="$(state)"
    echo "t+$(since)s $st"
    case "$st" in dead*) dead=$((dead + 1)) ;; esac
    [ "$dead" -ge 3 ] && return 1
    sleep 1
  done
  return 0
}

echo "::group::container start"
docker run -u root --cap-add SYS_ADMIN --privileged -dt --entrypoint /bin/bash \
  -v /dev/log:/dev/log --name "$NAME" "$IMG"
docker exec "$NAME" sh -c 'ls -la /opt/loxilb/*.o; md5sum /opt/loxilb/*.o' | tee "$OUT/objs.txt"
echo "::endgroup::"

T0="$(date +%s.%N)"
docker exec -d "$NAME" bash -c \
  '/root/loxilb-io/loxilb/loxilb > /tmp/loxilb.stdout 2> /tmp/loxilb.stderr; echo $? > /tmp/loxilb.exit'

echo "== timeline (loxilb started at t+0)"
if watch 60; then
  echo "== still alive after 60s: add a veth port, as the cicd scenarios do"
  pid="$(docker inspect -f '{{.State.Pid}}' "$NAME")"
  sudo ip link add dbgv0 type veth peer name dbgv1
  sudo ip link set dbgv1 netns "$pid"
  sudo nsenter -t "$pid" -n ip link set dbgv1 up
  sudo ip link set dbgv0 up
  if watch 40; then
    echo "== still alive: create an LB rule"
    docker exec "$NAME" loxicmd create lb 20.20.20.1 --tcp=2020:8080 \
      --endpoints=31.31.31.1:1 2>&1 | cut -c1-300
    echo "t+$(since)s $(state)"
    docker exec "$NAME" sh -c 'tc filter show dev dbgv1 ingress' 2>&1 | cut -c1-200
  fi
fi

echo "::group::collect"
docker cp "$NAME:/tmp/loxilb.stderr" "$OUT/loxilb.stderr"
docker cp "$NAME:/tmp/loxilb.stdout" "$OUT/loxilb.stdout"
docker exec "$NAME" sh -c 'cat /tmp/loxilb.exit 2>/dev/null || echo still-running' > "$OUT/exit.txt"
docker exec "$NAME" sh -c 'tar -C /var/log -cf - . 2>/dev/null' | tar -C "$OUT/varlog" -xf - 2>/dev/null
docker exec "$NAME" sh -c 'ls -la /opt/loxilb/dp/bpf 2>&1' > "$OUT/pins.txt"
docker exec "$NAME" sh -c 'bpftool prog show 2>&1' > "$OUT/bpftool-prog.txt"
docker exec "$NAME" sh -c 'bpftool map show 2>&1' > "$OUT/bpftool-map.txt"
sudo dmesg 2>/dev/null | tail -n 300 > "$OUT/dmesg.txt"
ls -la "$OUT" "$OUT/varlog"
echo "::endgroup::"

ERR="$OUT/loxilb.stderr"

echo "== loxilb exit: $(cat "$OUT/exit.txt")"
echo "== stderr: $(wc -c < "$ERR") bytes, $(wc -l < "$ERR") lines"

echo "== libbpf / verifier key lines"
grep -a -n -E 'libbpf: |BPF program is too large|processed [0-9]+ insns|verification time|PROG LOAD LOG|combined stack|back-edge|unreachable insn|too many (states|different)|Assertion|SIGSEGV|panic|fatal error' "$ERR" \
  | cut -c1-320 | head -n 150

echo "== verifier log: 40 lines before each END marker"
grep -a -n -B40 -e '-- END PROG LOAD LOG --' "$ERR" | cut -c1-320 | head -n 400

echo "== stderr head"
head -n 60 "$ERR" | cut -c1-320

echo "== stderr tail"
tail -n 80 "$ERR" | cut -c1-320

echo "== stdout tail"
tail -n 40 "$OUT/loxilb.stdout" | cut -c1-320

for f in "$OUT"/varlog/loxilb*; do
  [ -f "$f" ] || continue
  echo "== $f: $(wc -l < "$f") lines; tc/ebpf/error lines"
  grep -a -n -i -E 'tc: |ebpf|bpf|error|fail|critical' "$f" | cut -c1-320 | tail -n 80
  echo "== $f tail"
  tail -n 40 "$f" | cut -c1-320
done

echo "== pinned maps: $(grep -c . "$OUT/pins.txt") entries"
echo "== perf rings"
grep -a -A2 -E 'name (pkt_ring|cp_ring)' "$OUT/bpftool-map.txt" | cut -c1-200
echo "== loaded sched_cls programs"
grep -a -c sched_cls "$OUT/bpftool-prog.txt"
echo "== dmesg bpf lines"
grep -a -i -E 'bpf|verifier|loxilb|segfault|oom' "$OUT/dmesg.txt" | tail -n 30

exit 0
