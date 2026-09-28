import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { 
  ArrowLeft, 
  CheckCircle2, 
  AlertTriangle, 
  XCircle, 
  FileText, 
  School, 
  ShieldCheck, 
  HelpCircle,
  Clock,
  Send,
  MessageSquare
} from 'lucide-react';
import { adminApi } from '../services/adminApi';

export default function ReviewCase() {
  const { caseId } = useParams();
  const navigate = useNavigate();

  const [caseData, setCaseData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [actionSuccess, setActionSuccess] = useState(null);
  const [actionModal, setActionModal] = useState(null); // 'request_correction' | 'reject'
  const [modalNotes, setModalNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    async function loadCase() {
      setLoading(true);
      const data = await adminApi.getCaseDetail(caseId);
      setCaseData(data);
      setLoading(false);
    }
    loadCase();
  }, [caseId]);

  const handleApprove = async () => {
    setSubmitting(true);
    const res = await adminApi.submitCaseAction(
      caseId, 
      'approve', 
      'Officer verified AISHE affiliation alias. Approved.'
    );
    setActionSuccess({
      title: 'Verification Case Approved',
      message: 'Application status updated to Verified. Student notification dispatched to JAGO Mobile App.',
      status: 'Resolved'
    });
    setSubmitting(false);
  };

  const handleModalSubmit = async () => {
    if (!modalNotes.trim()) return;
    setSubmitting(true);
    const action = actionModal;
    await adminApi.submitCaseAction(caseId, action, modalNotes);
    setActionSuccess({
      title: action === 'reject' ? 'Application Rejected' : 'Correction Requested',
      message: action === 'reject' 
        ? `Application rejected with reason: "${modalNotes}". Student notified.` 
        : `Clarification requested from student: "${modalNotes}".`,
      status: action === 'reject' ? 'Rejected' : 'Under Review'
    });
    setActionModal(null);
    setSubmitting(false);
  };

  if (loading || !caseData) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  const isResolved = caseData.status === 'Resolved' || actionSuccess?.status === 'Resolved';

  return (
    <div className="p-8 space-y-6 max-w-5xl mx-auto">
      {/* Top Navigation */}
      <button
        onClick={() => navigate('/admin/reviews')}
        className="inline-flex items-center text-xs font-semibold text-slate-500 hover:text-slate-800 transition"
      >
        <ArrowLeft className="w-4 h-4 mr-1.5" />
        <span>Back to Review Queue</span>
      </button>

      {/* Case Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 bg-white p-6 rounded-xl border border-slate-200/90 shadow-sm">
        <div>
          <div className="flex items-center space-x-3">
            <span className="text-xl font-bold text-slate-900">
              Manual Review — Case #{caseData.case_number}
            </span>
            <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${
              isResolved 
                ? 'bg-emerald-100 text-emerald-800' 
                : 'bg-amber-100 text-amber-800'
            }`}>
              {actionSuccess?.status || caseData.status}
            </span>
          </div>
          <p className="text-xs text-slate-500 mt-1">
            Student: <strong className="text-slate-800 font-semibold">{caseData.student_name}</strong> • Scheme: <strong className="text-slate-800 font-semibold">Post-Matric Scholarship for ST Students</strong>
          </p>
        </div>

        <div className="flex items-center space-x-2">
          <span className="text-xs text-slate-500">Priority:</span>
          <span className="text-xs font-bold text-rose-600 bg-rose-50 border border-rose-200 px-2 py-0.5 rounded">
            {caseData.priority} Priority
          </span>
        </div>
      </div>

      {/* Action Success Banner if processed */}
      {actionSuccess && (
        <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-5 text-emerald-900 space-y-2">
          <div className="flex items-center space-x-2 font-bold text-sm text-emerald-800">
            <CheckCircle2 className="w-5 h-5 text-emerald-600" />
            <span>{actionSuccess.title}</span>
          </div>
          <p className="text-xs text-emerald-700 leading-relaxed">
            {actionSuccess.message}
          </p>
          <div className="pt-2">
            <button
              onClick={() => navigate('/admin/dashboard')}
              className="text-xs font-semibold bg-emerald-600 text-white px-3.5 py-1.5 rounded-lg hover:bg-emerald-700 transition"
            >
              Return to Dashboard
            </button>
          </div>
        </div>
      )}

      {/* Two Column Discrepancy Comparison */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Column 1: Student Submitted Data */}
        <div className="bg-white rounded-xl border border-slate-200/90 p-6 shadow-sm space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center space-x-2">
              <School className="w-4 h-4 text-blue-600" />
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700">
                Student Submitted Information
              </h3>
            </div>
            <span className="text-[10px] bg-blue-50 text-blue-700 font-semibold px-2 py-0.5 rounded border border-blue-200">
              Verified Profile
            </span>
          </div>

          <div className="space-y-3 text-xs">
            <div>
              <span className="text-slate-400 block text-[11px]">Institution Name Declared:</span>
              <span className="font-semibold text-slate-800 text-sm">
                ABC Institute of Technology
              </span>
            </div>

            <div>
              <span className="text-slate-400 block text-[11px]">Enrolled Course:</span>
              <span className="font-medium text-slate-700">
                B.Tech in Computer Science & Engineering
              </span>
            </div>

            <div>
              <span className="text-slate-400 block text-[11px]">Admission / Bonafide Reference:</span>
              <span className="font-mono text-slate-600">
                ADM/2026/TECH/0942
              </span>
            </div>
          </div>
        </div>

        {/* Column 2: Authorized Source Result */}
        <div className="bg-white rounded-xl border border-slate-200/90 p-6 shadow-sm space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center space-x-2">
              <ShieldCheck className="w-4 h-4 text-emerald-600" />
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700">
                Authorized Source Record
              </h3>
            </div>
            <span className="text-[10px] bg-emerald-50 text-emerald-700 font-semibold px-2 py-0.5 rounded border border-emerald-200">
              AISHE Directory
            </span>
          </div>

          <div className="space-y-3 text-xs">
            <div>
              <span className="text-slate-400 block text-[11px]">Official Registered Name:</span>
              <span className="font-semibold text-rose-600 text-sm">
                ABC Institute of Engineering
              </span>
            </div>

            <div>
              <span className="text-slate-400 block text-[11px]">AISHE Code:</span>
              <span className="font-mono font-semibold text-slate-800">
                C-49210
              </span>
            </div>

            <div>
              <span className="text-slate-400 block text-[11px]">Affiliated University:</span>
              <span className="font-medium text-slate-700">
                State Technical University, Jharkhand
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Analysis & Possible Reasons Box */}
      <div className="bg-slate-50 border border-slate-200 rounded-xl p-5 space-y-3 text-xs">
        <div className="flex items-center space-x-2 text-slate-800 font-bold">
          <HelpCircle className="w-4 h-4 text-emerald-600" />
          <span>Verification Diagnostic & Analysis</span>
        </div>
        <p className="text-slate-600 leading-relaxed">
          The Verification Orchestrator identified that the institution name differs in the suffix ("Technology" vs "Engineering"). The AISHE directory lists Code <strong>C-49210</strong> with the registered title "ABC Institute of Engineering", while the college commonly brands itself as "ABC Institute of Technology".
        </p>

        <div className="bg-white p-3.5 rounded-lg border border-slate-200 space-y-1.5">
          <span className="font-semibold text-slate-700 block">Possible Reasons:</span>
          <ul className="list-disc list-inside space-y-1 text-slate-600">
            <li>Student profile used informal or colloquial college campus branding</li>
            <li>Institution AISHE registry uses parent educational trust registration</li>
            <li>Submitted Bonafide Certificate matches the student registration and AISHE code</li>
          </ul>
        </div>
      </div>

      {/* Decision Actions */}
      {!isResolved && (
        <div className="bg-white rounded-xl border border-slate-200/90 p-6 shadow-sm">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700 mb-4">
            Officer Verification Action
          </h3>

          <div className="flex flex-col sm:flex-row gap-3">
            <button
              onClick={handleApprove}
              disabled={submitting}
              className="flex-1 inline-flex items-center justify-center px-4 py-2.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold shadow transition disabled:opacity-50"
            >
              <CheckCircle2 className="w-4 h-4 mr-2" />
              <span>Approve Alias & Validate Application</span>
            </button>

            <button
              onClick={() => {
                setActionModal('request_correction');
                setModalNotes('Please upload an updated Bonafide Certificate clearly stating both college name aliases.');
              }}
              disabled={submitting}
              className="inline-flex items-center justify-center px-4 py-2.5 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-bold shadow transition disabled:opacity-50"
            >
              <MessageSquare className="w-4 h-4 mr-2" />
              <span>Request Correction</span>
            </button>

            <button
              onClick={() => {
                setActionModal('reject');
                setModalNotes('Discrepancy cannot be resolved with current documentation.');
              }}
              disabled={submitting}
              className="inline-flex items-center justify-center px-4 py-2.5 rounded-lg bg-white border border-rose-300 hover:bg-rose-50 text-rose-600 text-xs font-bold shadow-sm transition disabled:opacity-50"
            >
              <XCircle className="w-4 h-4 mr-2" />
              <span>Reject with Reason</span>
            </button>
          </div>
        </div>
      )}

      {/* Modal for Request Correction / Reject */}
      {actionModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4">
            <h3 className="text-sm font-bold text-slate-900">
              {actionModal === 'reject' ? 'Reject Application' : 'Request Correction from Student'}
            </h3>
            <p className="text-xs text-slate-500">
              {actionModal === 'reject' 
                ? 'Provide a formal reason. This notification will be visible to the student in their JAGO app.' 
                : 'Specify what documents or details the student needs to re-submit.'}
            </p>

            <textarea
              rows={3}
              value={modalNotes}
              onChange={(e) => setModalNotes(e.target.value)}
              className="w-full p-3 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-800 focus:outline-none focus:ring-2 focus:ring-emerald-500"
              placeholder="Enter officer notes..."
            />

            <div className="flex justify-end space-x-2 pt-2">
              <button
                onClick={() => setActionModal(null)}
                className="px-3.5 py-1.5 rounded-lg border border-slate-200 text-slate-600 text-xs font-semibold hover:bg-slate-50"
              >
                Cancel
              </button>
              <button
                onClick={handleModalSubmit}
                disabled={submitting || !modalNotes.trim()}
                className={`px-4 py-1.5 rounded-lg text-white text-xs font-bold ${
                  actionModal === 'reject' ? 'bg-rose-600 hover:bg-rose-700' : 'bg-amber-600 hover:bg-amber-700'
                }`}
              >
                Submit Decision
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
